# Create cluster outbound IP
/*
resource "azurerm_public_ip" "k8s_pub_ip" {
  name                              = format("${var.k8s_dynamic.prefix}-mgmt")
  resource_group_name               = var.rg.name
  location                          = var.rg.location
  allocation_method                 = "Static"
  sku                               = "Standard"
}
*/

# Create K8s cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                              = var.k8s_dynamic.prefix
  resource_group_name               = var.rg.name
  location                          = var.rg.location
  dns_prefix                        = var.k8s_dynamic.prefix

  default_node_pool {
    name                            = var.k8s_static.node_pool_name
    vnet_subnet_id                  = var.data_subnet.id
    type                            = var.k8s_static.node_pool_type
    vm_size                         = var.k8s_static.vm_size
    enable_auto_scaling             = var.k8s_static.auto_scaling

    node_count                      = var.k8s_static.node_count
    min_count                       = var.k8s_static.node_min_count
    max_count                       = var.k8s_static.node_max_count

    linux_os_config {
      transparent_huge_page_enabled   = var.k8s_static.transparent_huge_page_enabled
    }
  }

  identity {
    type                            = var.k8s_static.identity
  }

  network_profile {
    network_plugin                  = var.k8s_static.network_plugin
    network_policy                  = var.k8s_static.network_policy
    load_balancer_sku               = var.k8s_static.load_balancer_sku
    outbound_type                   = var.k8s_static.outbound_type

    load_balancer_profile {
      managed_outbound_ip_count     = 1
#      outbound_ip_address_ids       = [azurerm_public_ip.k8s_pub_ip.id]
    }
  }
}


# Create container registry
resource "azurerm_container_registry" "acr" {
  name                              = var.k8s_dynamic.acr_name
  resource_group_name               = var.rg.name
  location                          = var.rg.location
  sku                               = var.k8s_static.registry.sku
  identity {
    type                            = var.k8s_static.registry.identity
  }
}

# Associate container registry with kubernetes cluster
resource "null_resource" "connect_aks_to_acr" {
  triggers = {
    aks = azurerm_kubernetes_cluster.main.name
    acr = azurerm_container_registry.acr.name
  }
  provisioner "local-exec" {
    when    = create
    environment = {
      aks_name  = azurerm_kubernetes_cluster.main.name
      acr_name  = azurerm_container_registry.acr.name
      rg_name   = var.rg.name
    }
    command   = "/usr/local/bin/az aks update -n $aks_name -g $rg_name --attach-acr $acr_name"
  }
}

