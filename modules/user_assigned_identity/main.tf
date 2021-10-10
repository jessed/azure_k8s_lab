
#data "azurerm_subscription"  "primary" {}
#data "azurerm_client_config" "client"  {}

data "azurerm_user_assigned_identity" "uai" {
  resource_group_name             = var.rg_name
  name                            = var.uai_name
}


