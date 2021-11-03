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



