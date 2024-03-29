output "host"                     { value = azurerm_kubernetes_cluster.main.kube_config.0.host }
output "aks_id"                   { value = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id }
output "username"                 { value = azurerm_kubernetes_cluster.main.kube_config.0.username }
output "password"                 { value = azurerm_kubernetes_cluster.main.kube_config.0.password }
output "client_key"               { value = azurerm_kubernetes_cluster.main.kube_config.0.client_key }
output "client_certificate"       { value = azurerm_kubernetes_cluster.main.kube_config.0.client_certificate }
output "cluster_ca_certificate"   { value = azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate }
