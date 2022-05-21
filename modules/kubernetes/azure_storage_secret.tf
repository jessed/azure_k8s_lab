## Kubernetes configuration
##

# Create secret for volume access
resource "kubernetes_secret" "azure" {
  type                      = "generic"
  metadata {
    name                    = var.storage.k8s_secret_name
    namespace               = "default"
  }
  data = {
    azurestorageaccountname = var.volume.account.name
    azurestorageaccountkey  = var.volume.account.primary_access_key
  }
}
