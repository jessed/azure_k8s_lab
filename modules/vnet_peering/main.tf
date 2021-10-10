# Reering relationships

# The 'transit' network is where BIG-IP is located

# Client to Transit
resource "azurerm_virtual_network_peering" "client_to_transit" {
  name                        = "client_to_transit"
  resource_group_name         = var.rg.name
  virtual_network_name        = var.client_vnet.name
  remote_virtual_network_id   = var.transit_vnet.id
}

# Transit to Client
resource "azurerm_virtual_network_peering" "transit_to_client" {
  name                        = "transit_to_client"
  resource_group_name         = var.rg.name
  virtual_network_name        = var.transit_vnet.name
  remote_virtual_network_id   = var.client_vnet.id
}


/*
# Necessary for BIG-IQ License Management if a Private-Link is not being used
data "azurerm_virtual_network" "bigiq" {
  count                       = var.bigiq.use_bigiq_lm == true ? 1 : 0
  resource_group_name         = var.bigiq.resource_group
  name                        = var.bigiq.vnet_name
}

# Transit to BIG-IQ
resource "azurerm_virtual_network_peering" "transit_to_bigiq" {
  count                       = var.bigiq.use_bigiq_lm == true ? 1 : 0
  name                        = "transit_to_bigiq"
  resource_group_name         = var.rg.name
  virtual_network_name        = var.transit_vnet.name
  remote_virtual_network_id   = data.azurerm_virtual_network.bigiq[0].id
}

# BIG-IQ to Transit (BIG-IP)
# Not necessary if BIG-IQ is only being used for license managment
# This is only necessary if you want to use BIG-IQ Centralized Management
resource "azurerm_virtual_network_peering" "bigiq_to_transit" {
  count                       = var.bigiq.use_bigiq_lm == true ? 1 : 0
  name                        = "bigiq_to_transit"
  resource_group_name         = var.bigiq.resource_group
  virtual_network_name        = data.azurerm_virtual_network.bigiq[0].name
  remote_virtual_network_id   = var.transit_vnet.id
}
*/
