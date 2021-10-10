k8s = {
  prefix                          = "jesseaks"
  identity                        = "SystemAssigned"
  load_balancer_sku               = "Standard"
  os_disk_type                    = "Managed"
  os_sku                          = "Ubuntu"
  node_pool_type                  = "VirtualMachineScaleSets"
  node_pool_name                  = "default"
  node_count                      = 2
  node_min_count                  = 2
  node_max_count                  = 5

  auto_scaling                    = true
  vm_size                         = "Standard_D2_v2"
  public_ips                      = false

  # linux os config
  transparent_huge_page_enabled   = "always"
  admin_username                  = "admin"
  private_cluster                 = false

  # Networking options
  network_plugin                  = "azure"
  network_policy                  = "calico"
  outbound_type                   = "loadBalancer"

  registry = {
   name                           = "acr"
   sku                            = "Standard"
   admin_enabled                  = false
   identity                       = "SystemAssigned"
  }
}
