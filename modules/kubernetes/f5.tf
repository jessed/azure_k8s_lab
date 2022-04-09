## Kubernetes configuration
##

# Create BIG-IP secrets
resource "kubernetes_secret" "bigip" {
  type                      = "generic"

  metadata {
    name                    = "bigip-login"
    namespace               = "kube-system"
  }
  data = {
    username                = var.f5_common.bigip_user
    password                = var.f5_common.bigip_pass
  }
}

# Create BIG-IP Service account
resource "kubernetes_service_account" "bigip" {
  metadata {
    name                    = "bigip-ctlr"
    namespace               = "kube-system"
  }
}

# Create cluster role
resource "kubernetes_cluster_role" "bigip" {
  metadata {
    name                    = "bigip-ctlr-clusterrole"
  }
  rule {
    api_groups              = ["", "extensions", "networking.k8s.io"]
    resources               = ["nodes", "services", "endpoints", "namespaces", "ingresses", "pods", "ingressclasses"]
    verbs                   = ["get", "list", "watch"]
  }
  rule {
    api_groups              = ["", "extensions", "networking.k8s.io"]
    resources               = ["configmaps", "events", "ingresses/status", "services/status"]
    verbs                   = ["get", "list", "watch", "update", "create", "patch"]
  }
  rule {
    api_groups              = ["cis.f5.com"]
    resources               = ["virtualservers","virtualservers/status", "tlsprofiles", "transportservers", "ingresslinks", "externaldnss"]
    verbs                   = ["get", "list", "watch", "update", "patch"]
  }
  rule {
    api_groups              = ["fic.f5.com"]
    resources               = ["f5ipams", "f5ipams/status"]
    verbs                   = ["get", "list", "watch", "update", "create", "patch", "delete"]
  }
  rule {
    api_groups              = ["apiextensions.k8s.io"]
    resources               = ["customresourcedefinitions"]
    verbs                   = ["get", "list", "watch", "update", "create", "patch"]
  }
  rule {
    api_groups              = ["", "extensions"]
    resources               = ["secrets"]
    verbs                   = ["get", "list", "watch"]
  }
}

# Create Cluster Role Binding
resource "kubernetes_cluster_role_binding" "bigip" {
  metadata {
    name                    = "bigip-ctlr-role_binding"
  }
  role_ref {
    name                    = "bigip-ctlr-clusterrole"
    kind                    = "ClusterRole"
    api_group               = "rbac.authorization.k8s.io"
  }
  subject {
    name                    = "bigip-ctlr"
    kind                    = "ServiceAccount"
    namespace               = "kube-system"
  }
}

