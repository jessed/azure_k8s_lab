# Storage details
storage = {
  name                    = "mvmltm"
  account_tier            = "Standard"
  replication_type        = "LRS"
  account_kind            = "StorageV2"

  min_tls_version         = "TLS1_0"
  public_access           = false
  network_default_action  = "Deny"

  container_name          = "f5-bigip"
  container_access        = "private"
}
