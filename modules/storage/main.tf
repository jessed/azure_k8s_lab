# Create storage account
resource "azurerm_storage_account" "primary" {
  name                            = format("%s%s", var.storage.name, var.rnd)
  resource_group_name             = var.rg.name
  location                        = var.rg.location
  account_tier                    = var.storage.account_tier
  account_replication_type        = var.storage.replication_type
  account_kind                    = var.storage.account_kind
  min_tls_version                 = var.storage.min_tls_version

  network_rules {
    default_action                = var.storage.network_default_action
    bypass                        = ["AzureServices","Metrics","Logging"]
    ip_rules                      = var.ip_rules
    virtual_network_subnet_ids    = var.subnet_ids
  }
}

# Create storage container for bigip configuration elements
resource "azurerm_storage_container" "container" {
  name                            = var.storage.bigip_container_name
  container_access_type           = var.storage.bigip_container_access
  storage_account_name            = azurerm_storage_account.primary.name
}

# Create bigip.conf file in storage container
resource "azurerm_storage_blob" "bigip_prod_conf" {
  name                        = "bigip_prod.conf"
  storage_account_name        = azurerm_storage_account.primary.name
  storage_container_name      = azurerm_storage_container.container.name
  type                        = "Block"
  source                      = "${path.root}/templates/bigip_prod.conf-template"
}

# Create bigip.conf-initial file in storage container
resource "azurerm_storage_blob" "bigip_common_conf" {
  name                        = "bigip_common.conf"
  storage_account_name        = azurerm_storage_account.primary.name
  storage_container_name      = azurerm_storage_container.container.name
  type                        = "Block"
  source                      = "${path.root}/templates/bigip_common.conf-template"
}

# Create file share for K8s volumes
resource "azurerm_storage_share" "kubernetes" {
  name                            = var.storage.k8s_share_name
  quota                           = var.storage.k8s_share_size
  storage_account_name            = azurerm_storage_account.primary.name

  acl {
    id                            = var.storage.k8s_share_acl_id
    access_policy {
      permissions                 = "rwdl"
    }
  }
}
