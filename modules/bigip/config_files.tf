# Config files to be created from templates

# System Onboarding script
resource "local_file" "bigip_onboard" {
  count   = var.bigip_count
  content = templatefile("${path.root}/templates/bigip_cloud_init.template", {
    cloud_init_log                = var.f5_common.cloud_init_log
    admin_user                    = var.f5_common.bigip_user
    admin_password                = var.f5_common.bigip_pass
    use_blob                      = var.f5_common.use_blob
    use_bigiq_license             = var.f5_common.use_bigiq_license
    BLOB                          = var.f5_common.blob
    USE_BLOB                      = var.f5_common.use_blob
    DO_FN                         = var.f5_common.DO_file
    TS_FN                         = var.f5_common.TS_file # TS config in log_analytics.tf
    AS3_FN                        = var.f5_common.AS3_file
    CFG_DIR                       = var.f5_common.cfg_dir
    DO_conf                       = base64encode(local_file.do_json[count.index].content)
    TS_conf                       = base64encode(local_file.ts_json.content)
    AS3_conf                      = base64encode(local_file.as3_json.content)
    # LTM config increases the onboarding script size beyond Azure's 89KB size limit
    #LTM_Config                    = base64encode(local_file.ltm_config[count.index].content)
    LTM_Config                    = base64encode("${path.root}/templates/ltm_config.conf-small")
    LTM_cfg_blob                  = var.f5_common.ltm_cfg_blob
    license_update                = base64encode(local_file.update_license.content)
    systemd_licensing             = filebase64("${path.root}/templates/update_license.service")
  })
  filename                        = "${path.root}/work_tmp/bigip_onboard.bash"
}

# Declarative-Onboarding config
resource "local_file" "do_json" {
  count   = var.bigip_count
  content = templatefile("${path.root}/templates/declarative_onboarding-bigiq_license_manager.json", {
    local_host                    = format("${var.bigip.prefix}%02d.${var.bigip.domain}", count.index+1)
    local_selfip                  = azurerm_network_interface.data_nic.*.private_ip_address[count.index]
    data_gateway                  = cidrhost(var.data_subnet.address_prefixes[0], 1)
    dns_server                    = var.bigip.dns_server
    ntp_server                    = var.bigip.ntp_server
    timezone                      = var.bigip.timezone
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

# LTM configuration
resource "local_file" "ltm_config" {
  count                           = var.bigip_count
  content = templatefile("${path.root}/templates/ltm_config.conf-template", {
    self_ip                       = azurerm_network_interface.data_nic.*.private_ip_address[count.index]
  })
  filename                        = "${path.root}/work_tmp/ltm_config.conf"
}

# update license script
resource "local_file" "update_license" {
  content = templatefile("${path.root}/templates/update_license.template", {
    bigIqHost                     = var.bigiq_host
    bigIqUser                     = var.bigiq.user
    bigIqPass                     = var.bigiq.pass
    bigIpUser                     = var.f5_common.bigip_user
    bigIpPass                     = var.f5_common.bigip_pass
  })
  filename                        = "${path.root}/work_tmp/update_license.bash"
}

