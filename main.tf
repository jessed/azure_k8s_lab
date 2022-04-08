terraform {
  required_providers {
    azurerm = {
      version = ">= 3.1.0"
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
      delete_nested_items_during_deletion = true      # defaults to true, but meh...
    }
  }
}

# Create random string to append to global names
resource "random_id" "uniq" {
  byte_length                 = 4
}


# Resource-Group
module "rg" {
  source                      = "./modules/resource_group"
  rg                          = local.rg
  rg_deployed                 = var.rg_deployed
}
 
# Create BIG-IP virtual-network and subnets
module "bigip_network" {
  source                      = "./modules/network"
  rg                          = module.rg.out
  vnet                        = local.vnet
  f5_common                   = local.f5_common
  vnet_deployed               = var.vnet_deployed
  subnets_deployed            = var.subnets_deployed
  subnets                     = local.subnets
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

# Create K8s cluster
module "aks" {
  source                      = "./modules/aks"
  rg                          = module.rg.out
  data_subnet                 = module.bigip_network.data_subnet
  aks_static                  = var.aks
  aks_dynamic                 = local.aks
}

# Have to force this provide to be dependent on the 'update_kubeconfig' resource
# to ensure that the config file is updated prior to sourcing that file.
# The provider cannot be called within the module directly.
provider "kubernetes" {
  host                        = module.aks.host
#  config_path                 = "~/.kube/config"
  username                    = module.aks.username
  password                    = module.aks.password
  client_key                  = base64decode(module.aks.client_key)
  client_certificate          = base64decode(module.aks.client_certificate)
  cluster_ca_certificate      = base64decode(module.aks.cluster_ca_certificate)
}

# Kubernetes configuration
module "k8s" {
  source                      = "./modules/kubernetes"
  f5_common                   = local.f5_common
  depends_on                  = [module.aks]
}

/*
# Storage and secure-container
module "storage" {
  source                      = "./modules/storage"
  rg                          = module.rg.out
  rnd                         = random_id.uniq.dec
  storage                     = var.storage
  ip_rules                    = local.nsg.mgmt.src_addrs
  subnet_ids                  = [
                                  module.bigip_network.data_subnet.id,
                                  module.bigip_network.mgmt_subnet.id,
                                ]
}

# User-Assigned Identity for secure-container access
module "uai" {
  source                      = "./modules/user_assigned_identity"
  rg                          = module.rg.out
  uai_name                    = local.f5_common.uai_name
  storage                     = module.storage.out
}

# Create Log Analytics Workspace
module "analytics" {
  source                      = "./modules/log_analytics"
  rg                          = module.rg.out
  law                         = local.log_analytics
  vnet                        = module.bigip_network.vnet
  subnet                      = module.bigip_network.mgmt_subnet
}

# Load-Balancer
# Mainly serves as a service connection for the Private-Link Service to
# BIG-IP
module "lb" {
  source                      = "./modules/load-balancer"
  lb                          = local.lb
  rg                          = module.rg.out
  subnet                      = module.bigip_network.data_subnet
}

# Create VMSS pool with BIG-IP members
module "vmss" {
  source                      = "./modules/vmss"
  count                       = var.bigip.use_vmss == true ? 1 : 0
  bigip                       = var.bigip
  rg                          = module.rg.out
  mgmt_subnet                 = module.bigip_network.mgmt_subnet
  data_subnet                 = module.bigip_network.data_subnet 
  mgmt_nsg                    = module.mgmt_nsg.out
  data_nsg                    = module.data_nsg.out
	lb_pool											= module.lb.pool
  f5_common                   = local.f5_common
  metadata                    = local.metadata
  bigiq_host                  = local.bigiq.host
  bigiq                       = local.bigiq
  analytics                   = local.log_analytics
  law                         = module.analytics.out
  uai                         = module.uai.out
  storage                     = module.storage.out
}

# Create standalone BIG-IP instance(s)
module "bigip" {
  source                      = "./modules/bigip"
  count                       = var.bigip.use_vmss == false ? 1 : 0
  bigip                       = var.bigip
  rg                          = module.rg.out
  mgmt_subnet                 = module.bigip_network.mgmt_subnet
  data_subnet                 = module.bigip_network.data_subnet 
  mgmt_nsg                    = module.mgmt_nsg.out
  data_nsg                    = module.data_nsg.out
	lb_pool											= module.lb.pool
  f5_common                   = local.f5_common
  metadata                    = local.metadata
  bigiq_host                  = local.bigiq.host
  bigiq                       = local.bigiq
  analytics                   = local.log_analytics
  law                         = module.analytics.out
  uai                         = module.uai.out
  storage                     = module.storage.out
}

# Clients
module "clients" {
  source                      = "./modules/clients"
  rg                          = module.rg.out
  nsg                         = module.mgmt_nsg.out
  client                      = var.clients
  f5_common                   = local.f5_common
  uai                         = module.uai.out
}

# VNET peering
module "peering" {
  source                      = "./modules/vnet_peering"
  rg                          = module.rg.out
  transit_vnet                = module.bigip_network.vnet
  client_vnet                 = module.clients.net
}

*/
