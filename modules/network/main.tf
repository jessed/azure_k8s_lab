# Create virtual-network and subnets

# Try to use an existing vnet first

data "azurerm_virtual_network" "main" {
  count                           = var.vnet_deployed == true ? 1 : 0
  name                            = var.vnet.name
  resource_group_name             = var.vnet.rg_name
}

data "azurerm_subnet" "mgmt_subnet" {
  count                           = var.subnets_deployed == true ? 1 : 0
  name                            = var.subnets.mgmt
  virtual_network_name            = var.vnet.name
  resource_group_name             = var.vnet.rg_name
}

data "azurerm_subnet" "data_subnet" {
  count                           = var.subnets_deployed == true ? 1 : 0
  name                            = var.subnets.data
  virtual_network_name            = var.vnet.name
  resource_group_name             = var.vnet.rg_name
}

# Create virtual-network
resource "azurerm_virtual_network" "main" {
  count                           = var.vnet_deployed == false ? 1 : 0
  name                            = var.vnet.name
  address_space                   = [var.vnet.cidr]
  resource_group_name             = var.vnet.rg_name
  location                        = var.rg.location
}


# Create management subnet
resource "azurerm_subnet" "mgmt_subnet" {
  count                           = var.subnets_deployed == false ? 1 : 0
  name                            = format("%s-mgmt", var.vnet.name)
  address_prefixes                = [cidrsubnet(var.vnet.cidr, 8, 0)]
  resource_group_name             = var.vnet.rg_name
  virtual_network_name            = try(azurerm_virtual_network.main[0].name, data.azurerm_virtual_network.main[0].name)
  service_endpoints = ["Microsoft.Storage"]

  # This endpoint is used to reach the Big-IQ PLS for licensing
  # PLS network services must be disabled and the PLE policies enabled to support the PL Endpoint
  enforce_private_link_endpoint_network_policies = true
}

# Create data subnet
resource "azurerm_subnet" "data_subnet" {
  count                           = var.subnets_deployed == false ? 1 : 0
  name                            = format("%s-data", var.vnet.name)
  address_prefixes                = [cidrsubnet(var.vnet.cidr, 8, 10)]
  resource_group_name             = var.vnet.rg_name
  virtual_network_name            = try(azurerm_virtual_network.main[0].name, data.azurerm_virtual_network.main[0].name)
  service_endpoints = ["Microsoft.Storage"]

  # This network carries data-plane traffic. To allow a Private-Link Service
  # to connect to the local ILB we must enable PLS network services
  enforce_private_link_service_network_policies = true
}

