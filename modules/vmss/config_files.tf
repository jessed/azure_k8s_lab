# Config files to be created from templates

# System Onboarding script
resource "local_file" "bigip_onboard" {
  content = templatefile("${path.root}/templates/vmss_cloud_init.template", {
    cloud_init_log                = var.f5_common.cloud_init_log
    admin_user                    = var.f5_common.bigip_user
    admin_password                = var.f5_common.bigip_pass
    use_bigiq_license             = var.vmss.use_paygo == false ? 1 : 0
    blob_path                     = "${var.storage.container.id}"
    DO_FN                         = var.f5_common.DO_file
    TS_FN                         = var.f5_common.TS_file # TS config in log_analytics.tf
    AS3_FN                        = var.f5_common.AS3_file
    CFG_DIR                       = var.f5_common.cfg_dir
    DO_conf                       = try(base64encode(local_file.do_json-byol[0].content),
                                        base64encode(local_file.do_json-payg[0].content))
    TS_conf                       = base64encode(local_file.ts_json.content)
    AS3_conf                      = base64encode(local_file.as3_json.content)
    ltm_config_b64                = ""
    ltm_cfg_file                  = var.f5_common.ltm_initial_cfg_file 
    license_update                = try(base64encode(local_file.update_license[0].content), "")
    systemd_licensing             = try(local_file.systemd_licensing[0].content, "")
  })
  filename                        = "${path.root}/work_tmp/bigip_onboard.bash"
}

# Declarative-Onboarding config
resource "local_file" "do_json-byol" {
  count   = var.vmss.use_paygo == false ? 1 : 0
  content = templatefile("${path.root}/templates/do-byol.json", {
    data_gateway                  = cidrhost(var.data_subnet.address_prefixes[0], 1)
    mgmt_gateway                  = cidrhost(var.mgmt_subnet.address_prefixes[0], 1)
    log_subnet                    = var.mgmt_subnet.address_prefixes[0]
    dns_server                    = var.vmss.dns_server
    ntp_server                    = var.vmss.ntp_server
    timezone                      = var.vmss.timezone
    bigIqHost                     = var.bigiq_host
    bigIqUsername                 = var.bigiq.user
    bigIqPassword                 = var.bigiq.pass
    bigIqLicenseType              = var.bigiq.lic_type
    bigIqLicensePool              = var.bigiq.lic_pool
    bigIqUnitOfMeasure            = var.bigiq.lic_measure
    bigIqHypervisor               = var.bigiq.lic_hypervisor
    bigIpUser                     = var.f5_common.bigip_user
    bigIpPass                     = var.f5_common.bigip_pass
  })
  filename                        = "${path.root}/work_tmp/do_file.json"
}

# Declarative-Onboarding config
resource "local_file" "do_json-payg" {
  count   = var.vmss.use_paygo == true ? 1 : 0
  content = templatefile("${path.root}/templates/do-payg.json", {
    data_gateway                  = cidrhost(var.data_subnet.address_prefixes[0], 1)
    mgmt_gateway                  = cidrhost(var.mgmt_subnet.address_prefixes[0], 1)
    log_subnet                    = var.mgmt_subnet.address_prefixes[0]
    dns_server                    = var.vmss.dns_server
    ntp_server                    = var.vmss.ntp_server
    timezone                      = var.vmss.timezone
    bigIpUser                     = var.f5_common.bigip_user
    bigIpPass                     = var.f5_common.bigip_pass
  })
  filename                        = "${path.root}/work_tmp/do_file.json"
}

# AS3 configuration
resource "local_file" "as3_json" {
  content = templatefile("${path.root}/templates/as3.json", {
  })
  filename                        = "${path.root}/work_tmp/as3.json"
}

# Telemetry-Streaming configuration
# Telemetry Streaming config
resource "local_file" "ts_json" {
  content = templatefile("${path.root}/templates/telemetry_streaming.json", {
    law_id                        = var.law.workspace_id
    law_primkey                   = var.law.primary_shared_key
    region                        = var.analytics.ts_region
  })
  filename                        = "${path.root}/work_tmp/ts_data.json"
}

# update license script
resource "local_file" "update_license" {
  count   = var.vmss.use_paygo == false ? 1 : 0
  content = templatefile("${path.root}/templates/update_license.template", {
    project                       = var.metadata.project
    bigIqHost                     = var.bigiq_host
    bigIqUser                     = var.bigiq.user
    bigIqPass                     = var.bigiq.pass
    bigIpUser                     = var.f5_common.bigip_user
    bigIpPass                     = var.f5_common.bigip_pass
  })
  filename                        = "${path.root}/work_tmp/update_license.bash"
}

# license service script object
resource "local_file" "systemd_licensing" {
  count                           = var.vmss.use_paygo == false ? 1 : 0
  content                         = filebase64("${path.root}/templates/update_license.service")
  filename                        = "${path.root}/work_tmp/systemd_licensing.service"
}

