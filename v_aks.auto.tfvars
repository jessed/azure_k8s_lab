aks = {
  prefix                            = "jesseaks"
  identity                          = "SystemAssigned"
  public_network_access_enabled     = true                # default: true
  role_based_access_control_enabled = true                # default: true
  private_cluster                   = false
  sku_tier                          = "Free"              # default: Free
  os_disk_type                      = "Managed"
  os_sku                            = "Ubuntu"

  # Load balancer options
  load_balancer_sku                 = "standard"
  idle_timeout                      = 4                   # default: 30

  # VMSS / Node options
  node_pool_type                    = "VirtualMachineScaleSets"
  node_pool_name                    = "default"
  node_count                        = 2
  node_min_count                    = 2
  node_max_count                    = 5
  auto_scaling                      = true
  vm_size                           = "Standard_D2_v2"
  public_ips                        = false

  # linux OS config
  transparent_huge_page_enabled     = "always"
  admin_username                    = "admin"

  # Networking options
  network_plugin                    = "azure"
  network_policy                    = "calico"
  outbound_type                     = "loadBalancer"

  registry = {
   name                             = "jesseacr"
   sku                              = "Standard"
   anonymous_pull                   = true    # default: false
   public_access                    = true    # default: true
   admin_enabled                    = false
   identity                         = "SystemAssigned"
  }
}
