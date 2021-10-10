# Input variables for LTM deployment within Azure

variable "subscription_id"  { default = "0f92c295-b01d-47ab-a709-1868040254df" }

variable "lab_prefix"       { default = "jessed-k8s_lab2" }
variable "vnet_cidr"        { default = "10.220.0.0/16" }
variable "node_count"       { default = 1 }                 # Number of client and server nodes
variable "bigip_count"      { default = 2 }                 # Number of BIG-IP VEs to deploy
variable "use_vmss"         { default = false }

# Reseource group locals
locals {
  secrets                   = jsondecode(file("${path.root}/secrets.json"))
  rg = {                    # Resource Group
    name                    = format("%s-rg", var.lab_prefix)
    location                = "westus2"
  }
}

# Virtual-network locals
locals {
  bigip_vnet = {            # virtual networks
    name                    = format("%s-bigip", var.lab_prefix)
    cidr                    = var.bigips.vnet_cidr
    subnets = {
      mgmt = {
        cidr                = [cidrsubnet(var.bigips.vnet_cidr, 8, 0)]
        pls_policy          = false     # allows PLS termination
        ple_policy          = true      # allows PLE endpoint
      }
      data = {
      	cidr                = [cidrsubnet(var.bigips.vnet_cidr, 8, 10)]
        pls_policy          = true
        ple_policy          = false
      }
      k8s = {
        cidr                = [cidrsubnet(var.bigips.vnet_cidr, 8, 20)]
        pls_policy          = true
        ple_policy          = false
      }
    }
  }
  clients_vnet = {          # virtual networks
    name                    = format("%s-clients", var.lab_prefix)
    cidr                    = var.clients.vnet_cidr
    subnets = {
      mgmt = {
        cidr                = [cidrsubnet(var.clients.vnet_cidr, 8, 0)]
        pls_policy          = false     # allows PLS termination
        ple_policy          = true      # allows PLE endpoint
      }
      data = {
      	cidr                = [cidrsubnet(var.clients.vnet_cidr, 8, 10)]
        pls_policy          = true
        ple_policy          = false
      }
    }
  }
}

locals {
  k8s = {
    prefix                  = var.k8s.prefix
    identity                = var.k8s.identity
    ssh_key                 = "~/.ssh/azure_f5.pub"
    username                = format("%s_%s", var.k8s.prefix, var.k8s.admin_username)
    acr_name                = format("%s%s", var.k8s.prefix, var.k8s.registry.name)
  }
  nsg = {                   # Network Security Group
    mgmt = {
      name                  = format("%s-mgmt-nsg", var.lab_prefix)
      dst_ports             = ["22","443", "8443"]
      src_addrs             = ["24.16.243.5","173.59.5.20","97.115.100.253"] # Permitted source addess(es)
    }
    data = {
      name                  = format("%s-data-nsg", var.lab_prefix)
      dst_ports             = ["80","443"]
      src_addrs             = ["0.0.0.0/0"] # Replace with your source addess(es)
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
    use_bigiq_license       = 1                               # 1 = Use BIG-IQ for licensing
                                                              # 0 = Don't attempt to retrieve a license from BIG-IQ
                                                              #     Set to 0 for use with PAYG images

    use_uai                 = false                           # Enable/Disable the use of a User Assigned Identity (UAI)
    uai_name                = local.secrets.uai_name          # UAI for container access
    uai_rg                  = "driskillRG"                    # UAI resource-group
    pls_name                = "perflab_pls"
    cloud_init_log          = "startup_script.log"            # cloud-init custom log file
    cfg_dir                 = "/shared/cloud_init"            # cloud-init custom working directory (mainly for troubleshooting)
    use_blob                = 0                               # 0 = Assume the *_file variables below are FQDNs to retrieve RPMs from an
                                                              #     external repository (over http/s)
                                                              # 1 = Use Azure secure container storage to retrieve RPMs from the *_file
                                                              #     variables below, which should contain only the file names, not the full FQDN
    blob                    = local.secrets.blob              # URL+Path to access Azure secure container
                                                              # UAI support is not yet available in this package. See README.
    AS3_file                = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.31.0/f5-appsvcs-3.31.0-6.noarch.rpm"
    DO_file                 = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.24.0/f5-declarative-onboarding-1.24.0-6.noarch.rpm"
    TS_file                 = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.23.0/f5-telemetry-1.23.0-4.noarch.rpm"
    # bigip.conf file suitable for merging into the running configuration
    ltm_cfg_file            = "https://raw.githubusercontent.com/jessed/nginx_proxy_map/main/bigip.conf"
  }
}


# These variables will be populated by the vars_bigips.tfvars, vars_clients.tfvars,
# and vars_servers.tfvars files respectively
variable "bigips"           {}
variable "vmss"             {}
variable "k8s"              {}
variable "clients"          {}

