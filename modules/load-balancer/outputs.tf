output "pool"     { value = azurerm_lb_backend_address_pool.lb_pool }
output "ip_id"    { value = azurerm_lb.lb.frontend_ip_configuration.0.id }
