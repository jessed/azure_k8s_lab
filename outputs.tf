output "login_with_docker"      { value = "az acr login -n ${var.aks.registry.name}" }
output "login_without_docker"   { value = "az acr login -n ${var.aks.registry.name} --expose-token" }
#output "enable_anonymous_pull"  { value = "az acr update -n ${var.aks.registry.name} --anonymous-pull-enabled true" }

