terraform {
  required_providers {
    azurerm = {
      version = ">= 2.20"
    }
  }
}
provider "azurerm" {
  features {
    virtual_machine {
      graceful_shutdown                   = true      # Necessary for license revocation when using BIG-IQ LM. 
      delete_os_disk_on_deletion          = true
    }
    template_deployment {
      delete_nested_items_during_deletion = true    # defaults to true, but meh...
    }
  }
}


# Resource-Group
module "rg" {
  source                      = "./modules/resource_group"
  rg                          = local.rg
}
 
# Create BIG-IP virtual-network and subnets
# If local.bigiq.use_bigiq_lm == true, this will also create a private-link-endpoint
# BIG-IQ LM
module "bigip_network" {
  source                      = "./modules/network"
  rg                          = module.rg.out
  vnet                        = local.bigip_vnet
  f5_common                   = local.f5_common
}

module "client_network" {
  source                      = "./modules/network"
  rg                          = module.rg.out
  vnet                        = local.client_vnet
  f5_common                   = local.f5_common
}

# Management Network-Security Group
module "mgmt_nsg" {
  source                      = "./modules/nsg"
  rg                          = module.rg.out
  nsg                         = local.nsg.mgmt
}

# Data Network-Security Group
module "data_nsg" {
  source                      = "./modules/nsg"
  rg                          = module.rg.out
  nsg                         = local.nsg.data
}

/*
module "analytics" {
  source                      = "./modules/log_analytics"
  rg                          = module.rg.out
  law                         = local.log_analytics
  vnet                        = module.bigip_network.vnet
  subnet                      = module.bigip_network.mgmt_subnet
}
*/

locals { bigiq_host = local.bigiq.host }

# Load-Balancer
# Mainly serves as a service connection for the Private-Link Service to 
# BIG-IP 
module "lb" {
  source                      = "./modules/load-balancer"
  rg                          = module.rg.out
  subnet                      = module.bigip_network.data_subnet
  lb                          = local.lb
}


# If provided, use a User-Assigned Identity
# NOTE: Everything works fine when a UAI is actually used, but when it isn't the 
# BIG-IP module fails due to the presence of the 'identity' block. For that reason, 
# UAI assignment has been disabled.
module "uai" {
  source                      = "./modules/user_assigned_identity"
  count                       = local.f5_common.use_uai == true ? 1 : 0
  rg_name                     = local.f5_common.uai_rg
  uai_name                    = local.f5_common.uai_name
}

# Create VMSS pool with BIG-IP members
module "vmss" {
  source                      = "./modules/vmss"
  count                       = var.use_vmss == true ? 1 : 0
  vmss                        = var.vmss
  rg                          = module.rg.out
  mgmt_subnet                 = module.bigip_network.mgmt_subnet
  data_subnet                 = module.bigip_network.data_subnet 
  log_subnet                  = module.bigip_network.log_subnet
  mgmt_nsg                    = module.mgmt_nsg.out
  data_nsg                    = module.data_nsg.out
  lb_pool                     = module.lb.pool
  f5_common                   = local.f5_common
  metadata                    = local.metadata
  bigiq_host                  = local.bigiq_host
  bigiq                       = local.bigiq
  analytics                   = local.log_analytics
  law                         = module.analytics.out
  #uai                        = module.uai[0].out
  servers                     = module.servers.hosts.priv_addr.*
  depends_on                  = [module.lb]
}

# Create BIG-IP instance(s)
# Use this module when a User-Assigned Identity is not being used
module "bigip" {
  source                      = "./modules/bigip"
  count                       = var.use_vmss == false ? 1 : 0
  bigip_count                 = var.bigip_count
  rg                          = module.rg.out
  mgmt_subnet                 = module.bigip_network.mgmt_subnet
  data_subnet                 = module.bigip_network.data_subnet
  nsg                         = module.nsg.out
  lb_pool                     = module.lb.pool
  f5_common                   = local.f5_common
  bigip                       = var.bigips
  bigiq_host                  = local.bigiq_host
  bigiq                       = local.bigiq
  analytics                   = local.log_analytics
  law                         = module.analytics.out
  depends_on                  = [module.lb]
}

# Create K8s cluster
module "k8s" {
  source                      = "./modules/k8s"
  rg                          = module.rg.out
  data_subnet                 = module.bigip_network.k8s_subnet
  k8s_static                  = var.k8s
  k8s_dynamic                 = local.k8s
}


# Clients
module "clients" {
  source                      = "./modules/clients"
  rg                          = module.rg.out
  nsg                         = module.mgmt_nsg.out
  client                      = var.clients
  mgmt_subnet                 = module.client_network.mgmt_subnet
  pls                         = module.pls.out
  f5_common                   = local.f5_common
  analytics                   = module.analytics.out
}

# VNET peering
module "peering" {
  source                      = "./modules/vnet_peering"
  rg                          = module.rg.out
  transit_vnet                = module.bigip_network.vnet
  client_vnet                 = module.client_network.net
  server_vnet                 = module.servers.net
  bigiq                       = local.bigiq
}
