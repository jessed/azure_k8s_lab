# Network-Security Group

# Create NSG
resource "azurerm_network_security_group" "nsg" {
  name                            = var.nsg.name
  resource_group_name             = var.rg.name
  location                        = var.rg.location
  timeouts { delete = "10m" }

  security_rule {
    name                          = "mgmt_access"
    description                   = "Allow mgmt access"
    priority                      = 100
    direction                     = "Inbound"
    access                        = "Allow"
    protocol                      = "Tcp"
    source_port_range             = "*"
    source_address_prefixes       = var.nsg.src_addrs
    destination_port_ranges       = var.nsg.dst_ports
    destination_address_prefix    = "*"
  }
}

