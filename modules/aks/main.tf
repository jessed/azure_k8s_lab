# Create cluster outbound IP
/*
resource "azurerm_public_ip" "aks_pub_ip" {
  name                              = format("${var.aks_dynamic.prefix}-mgmt")
  resource_group_name               = var.rg.name
  location                          = var.rg.location
  allocation_method                 = "Static"
  sku                               = "Standard"
}
*/

# Create AKS cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                              = var.aks_dynamic.prefix
  resource_group_name               = var.rg.name
  location                          = var.rg.location
  dns_prefix                        = var.aks_dynamic.prefix

  default_node_pool {
    name                            = var.aks_static.node_pool_name
    vnet_subnet_id                  = var.data_subnet.id
    type                            = var.aks_static.node_pool_type
    vm_size                         = var.aks_static.vm_size
    enable_auto_scaling             = var.aks_static.auto_scaling

    node_count                      = var.aks_static.node_count
    min_count                       = var.aks_static.node_min_count
    max_count                       = var.aks_static.node_max_count

    linux_os_config {
      transparent_huge_page_enabled   = var.aks_static.transparent_huge_page_enabled
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
#      outbound_ip_address_ids       = [azurerm_public_ip.aks_pub_ip.id]
    }
  }
}


# Create container registry
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


# Update ~/.kube/config
resource "null_resource" "update_kube_config" {
  triggers = { aks = azurerm_kubernetes_cluster.main.name }
  provisioner "local-exec" {
    environment = {
      aks_name  = azurerm_kubernetes_cluster.main.name
      rg_name   = var.rg.name
    }
    command = "az aks get-credentials -g $rg_name --name $aks_name"
  }
}
