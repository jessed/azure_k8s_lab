
# Create Private-Link Scope Endpoint
resource "azurerm_private_endpoint" "ampls" {
  count                       = var.law.use_ampls == true ? 1 : 0
  name                        = var.law.ampls_ple_name
  resource_group_name         = var.rg.name
  location                    = var.rg.location
  subnet_id                   = var.subnet.id

  private_service_connection {
    name                      = var.law.ampls_name
    is_manual_connection      = false
    private_connection_resource_id  = jsondecode(azurerm_resource_group_template_deployment.ampls[0].output_content).resourceID.value
    subresource_names         = ["azuremonitor"]
  }

  private_dns_zone_group {
    name                      = var.law.ampls_name
    private_dns_zone_ids      = [
      azurerm_private_dns_zone.monitor.id,
      azurerm_private_dns_zone.oms.id,
      azurerm_private_dns_zone.ods.id,
      azurerm_private_dns_zone.agentsvc.id,
      azurerm_private_dns_zone.blob.id
    ]
  }
}


# create private zones and records for PLE
#
resource "azurerm_private_dns_zone" "monitor" {
  name                          = "privatelink.monitor.azure.com"
  resource_group_name           = var.rg.name
}

resource "azurerm_private_dns_zone" "oms" {
  name                          = "privatelink.oms.opinsights.azure.com"
  resource_group_name           = var.rg.name
}

resource "azurerm_private_dns_zone" "ods" {
  name                          = "privatelink.ods.opinsights.azure.com"
  resource_group_name           = var.rg.name
}

resource "azurerm_private_dns_zone" "agentsvc" {
  name                          = "privatelink.agentsvc.azure-automation.net"
  resource_group_name           = var.rg.name
}

resource "azurerm_private_dns_zone" "blob" {
  name                          = "privatelink.blob.core.windows.net"
  resource_group_name           = var.rg.name
}

# Create private records
resource "azurerm_private_dns_a_record" "monitor_api" {
  name                          = "api"
  zone_name                     = azurerm_private_dns_zone.monitor.name
  resource_group_name           = var.rg.name
  ttl                           = 3600
  records                       = [cidrhost(var.subnet.address_prefixes[0], 7)]
}

# monitor
resource "azurerm_private_dns_a_record" "monitor_global" {
  name                          = "global.in.ai"
  zone_name                     = azurerm_private_dns_zone.monitor.name
  resource_group_name           = var.rg.name
  ttl                           = 3600
  records                       = [cidrhost(var.subnet.address_prefixes[0], 8)]
}

resource "azurerm_private_dns_a_record" "monitor_profiler" {
  name                          = "profiler"
  zone_name                     = azurerm_private_dns_zone.monitor.name
  resource_group_name           = var.rg.name
  ttl                           = 3600
  records                       = [cidrhost(var.subnet.address_prefixes[0], 9)]
}

resource "azurerm_private_dns_a_record" "monitor_live" {
  name                          = "live"
  zone_name                     = azurerm_private_dns_zone.monitor.name
  resource_group_name           = var.rg.name
  ttl                           = 3600
  records                       = [cidrhost(var.subnet.address_prefixes[0], 10)]
}

resource "azurerm_private_dns_a_record" "monitor_snapshot" {
  name                          = "snapshot"
  zone_name                     = azurerm_private_dns_zone.monitor.name
  resource_group_name           = var.rg.name
  ttl                           = 3600
  records                       = [cidrhost(var.subnet.address_prefixes[0], 11)]
}

resource "azurerm_private_dns_zone_virtual_network_link" "monitor-net" {
  name                          = "pl-monitor-net"
  resource_group_name           = var.rg.name
  private_dns_zone_name         = azurerm_private_dns_zone.monitor.name
  virtual_network_id            = var.vnet.id
}

# oms
resource "azurerm_private_dns_a_record" "oms_law_id" {
  name                          = azurerm_log_analytics_workspace.law.workspace_id
  zone_name                     = azurerm_private_dns_zone.oms.name
  resource_group_name           = var.rg.name
  ttl                           = 3600
  records                       = [cidrhost(var.subnet.address_prefixes[0], 4)]
}

resource "azurerm_private_dns_zone_virtual_network_link" "oms-net" {
  name                          = "pl-oms-net"
  resource_group_name           = var.rg.name
  private_dns_zone_name         = azurerm_private_dns_zone.oms.name
  virtual_network_id            = var.vnet.id
}

# ods
resource "azurerm_private_dns_a_record" "ods_law_id" {
  name                          = azurerm_log_analytics_workspace.law.workspace_id
  zone_name                     = azurerm_private_dns_zone.ods.name
  resource_group_name           = var.rg.name
  ttl                           = 3600
  records                       = [cidrhost(var.subnet.address_prefixes[0], 5)]
}

resource "azurerm_private_dns_zone_virtual_network_link" "ods-net" {
  name                          = "pl-ods-net"
  resource_group_name           = var.rg.name
  private_dns_zone_name         = azurerm_private_dns_zone.ods.name
  virtual_network_id            = var.vnet.id
}

# agentsvc
resource "azurerm_private_dns_a_record" "agentsvc_law_id" {
  name                          = azurerm_log_analytics_workspace.law.workspace_id
  zone_name                     = azurerm_private_dns_zone.agentsvc.name
  resource_group_name           = var.rg.name
  ttl                           = 3600
  records                       = [cidrhost(var.subnet.address_prefixes[0], 6)]
}

resource "azurerm_private_dns_zone_virtual_network_link" "agentsvc-net" {
  name                          = "pl-agentsvc-net"
  resource_group_name           = var.rg.name
  private_dns_zone_name         = azurerm_private_dns_zone.agentsvc.name
  virtual_network_id            = var.vnet.id
}

# blob
resource "azurerm_private_dns_a_record" "blob_scadvisorcontentpld" {
  name                          = "scadvisorcontentpl"
  zone_name                     = azurerm_private_dns_zone.blob.name
  resource_group_name           = var.rg.name
  ttl                           = 3600
  records                       = [cidrhost(var.subnet.address_prefixes[0], 12)]
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob-net" {
  name                          = "pl-blob-net"
  resource_group_name           = var.rg.name
  private_dns_zone_name         = azurerm_private_dns_zone.blob.name
  virtual_network_id            = var.vnet.id
}

