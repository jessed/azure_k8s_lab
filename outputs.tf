output "acr_login" {
  value       = "az acr login -n ${module.aks.acr_name}"
}
