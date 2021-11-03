
output "out" { value = try(azurerm_resource_group.rg[0], data.azurerm_resource_group.rg[0]) }
