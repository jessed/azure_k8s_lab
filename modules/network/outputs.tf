output "vnet"         { value = try(azurerm_virtual_network.main[0], data.azurerm_virtual_network.main[0]) }
output "mgmt_subnet"  { value = try(azurerm_subnet.mgmt_subnet[0], data.azurerm_subnet.mgmt_subnet[0]) }
output "data_subnet"  { value = try(azurerm_subnet.data_subnet[0], data.azurerm_subnet.mgmt_subnet[0]) }
