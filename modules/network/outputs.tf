output "vnet"         { value = azurerm_virtual_network.main }
output "mgmt_subnet"  { value = try(azurerm_subnet.subnets["mgmt"], null) }
output "data_subnet"  { value = try(azurerm_subnet.subnets["data"], null) }
output "k8s_subnet"   { value = try(azurerm_subnet.subnets["k8s"],  null) }

