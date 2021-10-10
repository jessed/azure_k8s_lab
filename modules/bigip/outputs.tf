output "public_ip" { value = azurerm_public_ip.mgmt_pub_ip.*.ip_address }

