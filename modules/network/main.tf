# Networking and NSG

# Create virtual-network
resource "azurerm_virtual_network" "main" {
  name                            = var.vnet.name
  address_space                   = [var.vnet.cidr]
  resource_group_name             = var.rg.name
  location                        = var.rg.location
}

# Create subnets defined in base vars.tf
resource "azurerm_subnet" "subnets" {
  resource_group_name                               = var.rg.name
  virtual_network_name                              = azurerm_virtual_network.main.name
  for_each                                          = var.vnet.subnets
    name                                            = format("%s-%s", azurerm_virtual_network.main.name, each.key)
    address_prefixes                                = each.value.cidr
    enforce_private_link_endpoint_network_policies  = each.value.ple_policy
    enforce_private_link_service_network_policies   = each.value.pls_policy
}
