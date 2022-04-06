# Input variables for LTM deployment within Azure

variable "subscription_id"  { default = "0f92c295-b01d-47ab-a709-1868040254df" }

variable "lab_prefix"       { default = "jessed-aks-lab" }
variable "node_count"       { default = 1 }                 # Number of client and server nodes
variable "bigip_count"      { default = 2 }                 # Number of BIG-IP VEs to deploy
variable "vnet_cidr"        { default = "10.210.0.0/16" }


# Whether resource-group and virtual-network have already
# been deployed outside of this terraform package
variable "rg_deployed"      { default = false }                 # Does this resource-group already exist?
variable "vnet_deployed"    { default = false }                 # Does this vnet already exist?
variable "subnets_deployed" { default = false }                 # Does this subnet already exist?

# If using a pre-existing vnet, add it's resource-group name and the subnet names here
locals {
  existing_vnet_name        = "existing-westus2-dev-vnet"
  existing_rg_name          = "existing-westus2-dev-rg"
  subnets = {
    mgmt                    = format("%s-mgmt", local.vnet.name)
    data                    = format("%s-data", local.vnet.name)
  }
}

locals {
  metadata = {
    project                 = "aks_lab"
  }
}



locals {
  secrets                   = jsondecode(file("${path.root}/secrets.json"))
  rg = {                    # Resource Group
    name                    = format("%s-rg", var.lab_prefix)
    location                = "westus2"
  }
  aks = {
    prefix                  = var.aks.prefix
    identity                = var.aks.identity
    ssh_key                 = "~/.ssh/azure_f5.pub"
    username                = format("%s_%s", var.aks.prefix, var.aks.admin_username)
    acr_name                = format("%s%s", var.aks.prefix, var.aks.registry.name)
  }
  vnet = {                  # virtual networks
    name                    = var.vnet_deployed == false ? "jessnet-bigip" : local.existing_vnet_name
    cidr                    = var.vnet_cidr
    rg_name                 = var.rg_deployed == false ? local.rg.name : local.existing_rg_name
  }
  nsg = {                   # Network security group
    mgmt = {
      name                    = format("%s-mgmt-nsg", var.lab_prefix)
      dst_ports               = ["22","443", "8443"]
      src_addrs               = ["104.219.104.84","73.140.91.132"] # Replace with your source addess(es)
    }
    data = {
      name                    = format("%s-data-nsg", var.lab_prefix)
      dst_ports               = ["80","443"]
      src_addrs               = ["0.0.0.0/0"] # Replace with your source addess(es)
    }
  }
  log_analytics = {         # Log Analytics Workspace
    name                    = format("%s-law", var.lab_prefix)
    retention               = "30"
    sku                     = "PerNode"
    ts_region               = "us-west-2"
    ts_type                 = "Azure_Log_Analytics"
    ts_log_group            = "f5telemetry"
    ts_log_stream           = "default"
    internet_ingestion      = true
    internet_query          = true
    use_ampls               = true                                 # Azure Monitory Private Link Scope (AMPLS)
    ampls_name              = "ampls_monitor"
    ampls_ple_name          = "ampls_ple"
    ampls_dns_name          = "ampls_dns"
    workbook_name           = "VE_usage"
    workbook_type           = "workbook"
  }
  lb = {                    # load-balancer; required for Private-Link Service
    use_lb                  = 1
    name                    = format("%s-lb", var.lab_prefix)
    pool_name               = "lb_pool"
    sku                     = "Standard"
    priv_allocation         = "Dynamic"
    priv_version            = "IPv4"
  }
  bigiq = {                 # BIG-IQ License Manager (for BYOL licensing)
    use_bigiq_lm            = false
    use_bigiq_pls           = false
    pls_name                = "jesssnet-PLS_BigIQ"
    vnet_name               = "jessenet-Bastion"
    ple_name                = format("%s-bigiq_ple", var.lab_prefix)
    resource_group          = "driskillRG"                    # Resource-Group containing BIG-IQ virtual-network and PLS
    host                    = local.secrets.bigiq_host
    user                    = local.secrets.bigiq_user
    pass                    = local.secrets.bigiq_pass
    lic_type                = "licensePool"
    lic_pool                = "azure_test"
    lic_measure             = "yearly"
    lic_hypervisor          = "azure"
    reachable               = false
  }
  f5_common = {             # Common variables used by many modules
    bigip_user              = local.secrets.bigip_user
    bigip_pass              = local.secrets.bigip_pass
    public_key              = "~/.ssh/azure_f5.pub"           # Public key for SSH authentication

    pls_name                = "perflab_pls"
    cloud_init_log          = "startup_script.log"            # cloud-init custom log file
    cfg_dir                 = "/shared/cloud_init"            # cloud-init custom working directory (mainly for troubleshooting)

    uai_name                = local.secrets.uai_name          # UAI for container access

    AS3_file                = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.31.0/f5-appsvcs-3.31.0-6.noarch.rpm"
    DO_file                 = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.24.0/f5-declarative-onboarding-1.24.0-6.noarch.rpm"
    TS_file                 = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.23.0/f5-telemetry-1.23.0-4.noarch.rpm"

    # bigip.conf file suitable for merging into the running configuration
    ltm_initial_cfg_file    = "bigip_common.conf"
  }
}


# These variables will be populated by the vars_bigips.tfvars, vars_clients.tfvars,
# and vars_servers.tfvars files respectively
variable "bigip"            {}
variable "clients"          {}
variable "storage"          {}
variable "aks"							{}
