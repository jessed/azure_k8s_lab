# Storage details
storage = {
  name                    = "jesseaks"
  account_tier            = "Standard"
  replication_type        = "LRS"
  account_kind            = "StorageV2"

  min_tls_version         = "TLS1_0"
  public_access           = false
  network_default_action  = "Deny"

  bigip_container_name    = "f5-bigip"
  bigip_container_access  = "private"

  k8s_share_name          = "kubernetes"
  k8s_share_acl_id        = "k8s_access_id"
  k8s_share_size          = 5
  k8s_share_protocol      = "SMB"     # NFS requires "Premium" account_tier
  k8s_secret_name         = "storage-secret"
}
