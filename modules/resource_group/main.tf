data "azurerm_resource_group" "rg" {
  count     = var.rg_deployed == true ? 1 : 0
  name      = var.rg.name
}

resource "azurerm_resource_group" "rg" {
  count     = var.rg_deployed == false ? 1 : 0
  name      = var.rg.name
  location  = var.rg.location
}
