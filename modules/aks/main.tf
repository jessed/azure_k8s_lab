# Create AKS cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                              = var.aks_dynamic.prefix
  resource_group_name               = var.rg.name
  location                          = var.rg.location
  sku_tier                          = var.aks_static.sku_tier
  dns_prefix                        = var.aks_dynamic.prefix
  public_network_access_enabled     = var.aks_static.public_network_access_enabled
  role_based_access_control_enabled = var.aks_static.role_based_access_control_enabled

  node_resource_group               = var.aks_dynamic.node_resource_group
  default_node_pool {
    name                            = var.aks_static.node_pool_name
    vnet_subnet_id                  = var.data_subnet.id
    type                            = var.aks_static.node_pool_type
    vm_size                         = var.aks_static.vm_size
    enable_auto_scaling             = var.aks_static.auto_scaling

    node_count                      = var.aks_static.node_count
    min_count                       = var.aks_static.node_min_count
    max_count                       = var.aks_static.node_max_count

    enable_node_public_ip           = false

    linux_os_config {
      transparent_huge_page_enabled = var.aks_static.transparent_huge_page_enabled
    }
  }

  identity {
    type                            = var.aks_static.identity
  }

  network_profile {
    network_plugin                  = var.aks_static.network_plugin
    network_policy                  = var.aks_static.network_policy
    load_balancer_sku               = var.aks_static.load_balancer_sku
    outbound_type                   = var.aks_static.outbound_type

    load_balancer_profile {
      managed_outbound_ip_count     = 1
      idle_timeout_in_minutes       = var.aks_static.idle_timeout
#      outbound_ip_address_ids       = [azurerm_public_ip.aks_pub_ip.id]
    }
  }
}

# Create or Update ~/.kube/config
resource "null_resource" "update_kubeconfig" {
  triggers = {
    aks_name    = azurerm_kubernetes_cluster.main.name
  }

  provisioner "local-exec" {
    environment = {
      aks_name  = azurerm_kubernetes_cluster.main.name
      rg_name   = var.rg.name
      user_name = "clusterUser_${var.rg.name}_${azurerm_kubernetes_cluster.main.name}"
    }
    command = "az aks get-credentials -g $rg_name --name $aks_name"
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "kubectl config delete-context $aks_name"
  }
  provisioner "local-exec" {
    when        = destroy
    command     = "kubectl config delete-cluster $aks_name"
  }
  provisioner "local-exec" {
    when        = destroy
    #command     = "kubectl config delete-user clusterUser_${rg_name}_${aks_name}"
    command     = "kubectl config delete-user $user_name"
  }
}

/*
# Create container registry - MOVED to acr module
resource "azurerm_container_registry" "acr" {
  name                              = var.aks_dynamic.acr_name
  resource_group_name               = var.rg.name
  location                          = var.rg.location
  sku                               = var.aks_static.registry.sku
  identity {
    type                            = var.aks_static.registry.identity
  }
  depends_on                        = [azurerm_kubernetes_cluster.main]
}

# Attach container registry to AKS cluster - MOVED to acr module
resource "azurerm_role_assignment" "main" {
  principal_id                      = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name              = "AcrPull"
  scope                             = azurerm_container_registry.acr.id
  skip_service_principal_aad_check  = true
}

# Create cluster outbound IP
resource "azurerm_public_ip" "aks_pub_ip" {
  name                              = format("${var.aks_dynamic.prefix}-mgmt")
  resource_group_name               = var.rg.name
  location                          = var.rg.location
  allocation_method                 = "Static"
  sku                               = "Standard"
}
*/

