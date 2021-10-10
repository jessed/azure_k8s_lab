#output "name"     { value = azurerm_resource_group.rg.name }
#output "location" { value = azurerm_resource_group.rg.location }

output "out" {
  value = {
    id        = azurerm_resource_group.rg.id
    name      = azurerm_resource_group.rg.name
    location  = azurerm_resource_group.rg.location
  }
}
