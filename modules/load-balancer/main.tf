# Create lb 

# front-end IP address
#resource "azurerm_public_ip" "lb_address" {
#  name                            = "${local.lb_name}_ip"
#  resource_group_name             = var.rg.name
#  location                        = var.rg.location
#  allocation_method               = "Static"
#  sku                             = "Standard"
#}

# load-balancer
resource "azurerm_lb" "lb" {
  name                            = var.lb.name
  resource_group_name             = var.rg.name
  location                        = var.rg.location
  sku                             = var.lb.sku

  frontend_ip_configuration {
    name                          = "${var.lb.name}_frontend"
    subnet_id                     = var.subnet.id
    private_ip_address_allocation = var.lb.priv_allocation
    private_ip_address_version    = var.lb.priv_version
  }
}

resource "azurerm_lb_probe" "nva_probe" {
  name                            = "port_65000"
  resource_group_name             = var.rg.name
  loadbalancer_id                 = azurerm_lb.lb.id
  port                            = 65000
}

resource "azurerm_lb_backend_address_pool" "lb_pool" {
  name                            = var.lb.pool_name
  #resource_group_name             = var.rg.name
  loadbalancer_id                 = azurerm_lb.lb.id

  timeouts {
    update = "10m"
    delete = "10m"
  }
}

resource "azurerm_lb_rule" "ha_rule" {
  name                            = "all_ports"
  resource_group_name             = var.rg.name
  loadbalancer_id                 = azurerm_lb.lb.id
  protocol                        = "All"
  frontend_port                   = 0
  backend_port                    = 0
  backend_address_pool_id         = azurerm_lb_backend_address_pool.lb_pool.id
  probe_id                        = azurerm_lb_probe.nva_probe.id
  enable_tcp_reset                = true
  frontend_ip_configuration_name  = "${var.lb.name}_frontend"
#  frontend_ip_configuration_name  = azurerm_lb.lb.frontend_ip_configuration[0].name
}
