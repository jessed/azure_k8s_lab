# Create Private-Link Service
resource "azurerm_private_link_service" "pls" {
  name                                          = var.pls_name
  resource_group_name                           = var.rg.name
  location                                      = var.rg.location
  enable_proxy_protocol                         = true

  auto_approval_subscription_ids                = [var.subscription_id]
  visibility_subscription_ids                   = [var.subscription_id]

  load_balancer_frontend_ip_configuration_ids   = [var.frontend_ip_id]

  nat_ip_configuration {
    name                                        = "primary"
    private_ip_address_version                  = "IPv4"
    subnet_id                                   = var.data_subnet.id
    primary                                     = true
  }
}
