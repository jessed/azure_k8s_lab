# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  resource_group_name         = var.rg.name
  location                    = var.rg.location
  name                        = var.law.name
  retention_in_days           = var.law.retention
  sku                         = var.law.sku
  internet_ingestion_enabled  = var.law.internet_ingestion
  internet_query_enabled      = var.law.internet_query
}

/*
# Create VE usage workbook in log analytics workspace
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment
resource "azurerm_resource_group_template_deployment" "ve_usage" {
  name                            = var.law.workbook_name
  resource_group_name             = var.rg.name
  deployment_mode                 = "Incremental"

  parameters_content              = jsonencode({
    workbookDisplayName           = { value = var.law.workbook_name }
    workbookType                  = { value = var.law.workbook_type }
    workbookSourceId              = { value = azurerm_log_analytics_workspace.law.id }
    location                      = { value = var.rg.location }
  })
  template_content                = file("${path.root}/templates/ve_usage_workbook.arm.json")
}


# Create Azure Monitor Private Link Scope for communication with log analytics workspace
resource "azurerm_resource_group_template_deployment" "ampls" {
  count                       = var.law.use_ampls == true ? 1 : 0
  name                        = var.law.ampls_name
  resource_group_name         = var.rg.name
  deployment_mode             = "Incremental"

  parameters_content          = jsonencode({
    "private_link_scope_name" = { value = var.law.ampls_name }
    "workspace_name"          = { value = azurerm_log_analytics_workspace.law.name }
  })
  template_content            = file("${path.root}/templates/ampls.arm.json")
}
*/
