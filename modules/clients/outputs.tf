output "out" {
  value = {
    hostname    = azurerm_linux_virtual_machine.host.*.name
    address     = azurerm_public_ip.node_public_ip.*.ip_address
  }
}
output "net"  {
  value = {
    name        = azurerm_virtual_network.vnet.name
    id          = azurerm_virtual_network.vnet.id
  }
}
