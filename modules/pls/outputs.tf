#output "out" {
#  value = {
#    name  = "azurerm_private_link_service.pls.name"
#    id    = "azurerm_private_link_service.pls.id"
#  }
#}
output "out" { value = azurerm_private_link_service.pls }
