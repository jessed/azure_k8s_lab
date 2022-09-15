# Create container registry
resource "azurerm_container_registry" "acr" {
  name                              = var.aks_dynamic.acr_name
  resource_group_name               = var.rg.name
  location                          = var.rg.location
  anonymous_pull_enabled            = var.aks_static.registry.anonymous_pull
  public_network_access_enabled     = var.aks_static.registry.public_access
  sku                               = var.aks_static.registry.sku
  identity {
    type                            = var.aks_static.registry.identity
  }
}

# Attach container registry to AKS cluster
resource "azurerm_role_assignment" "main" {
  principal_id                      = var.aks_id
  role_definition_name              = "AcrPull"
  scope                             = azurerm_container_registry.acr.id
  skip_service_principal_aad_check  = true
}
