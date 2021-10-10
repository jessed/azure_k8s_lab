# All resources required for client

# Create Public IP
resource "azurerm_public_ip" "node_public_ip" {
  count                           = var.client.node.count
  name                            = format("${var.client.node.prefix}%02d_pub_ip", count.index+1)
  location                        = var.rg.location
  resource_group_name             = var.rg.name
  allocation_method               = "Static"
}

# Create NIC
resource "azurerm_network_interface" "node_nic" {
  count                           = var.client.node.count
  name                            = format("${var.client.node.prefix}%02d_nic", count.index+1)
  location                        = var.rg.location
  resource_group_name             = var.rg.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.mgmt_subnet.id
    public_ip_address_id          = azurerm_public_ip.node_public_ip.*.id[count.index]
    private_ip_address_allocation = "Dynamic"
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "node_sec" {
  count                           = var.client.node.count
  network_interface_id            = azurerm_network_interface.node_nic.*.id[count.index]
  network_security_group_id       = var.nsg.id
}

# Create VM
resource "azurerm_linux_virtual_machine" "host" {
  count                           = var.client.node.count
  computer_name                   = format("${var.client.node.prefix}%02d.${var.client.node.domain}", count.index+1)
  name                            = format("${var.client.node.prefix}%02d", count.index+1)
  location                        = var.rg.location
  resource_group_name             = var.rg.name
  network_interface_ids           = [azurerm_network_interface.node_nic.*.id[count.index]]
  size                            = var.client.node.image.size
  admin_username                  = var.client.node.user
  disable_password_authentication = true

  custom_data                     = base64gzip(local_file.linux_host_init.content)

  os_disk {
    name                          = format("${var.client.node.prefix}%02d_disk", count.index+1)
    caching                       = "ReadWrite"
    storage_account_type          = var.client.node.image.disk
  }

  source_image_reference {
    publisher                     = var.client.node.image.publisher
    offer                         = var.client.node.image.offer
    sku                           = var.client.node.image.sku
    version                       = var.client.node.image.version
  }

  admin_ssh_key {
    username                      = var.client.node.user
    public_key                    = file(var.f5_common.public_key)
  }

  # Update local hosts file with system address
  provisioner "local-exec" {
    command   = "${path.root}/scripts/update_hosts.bash ${self.name} ${self.public_ip_address}"
  }
}

resource "local_file" "linux_host_init" {
  content = templatefile("${path.root}/templates/linux_host_init.template", {
    sudoers                       = filebase64("${path.root}/templates/host_sudoers")
    test_script                   = ""
  })
  filename                        = "${path.root}/work_tmp/linux_host_init.bash"
}

/*
resource "local_file" "test_script" {
  content = templatefile("${path.root}/templates/tests.bash.template", {
    ple_ip                        = azurerm_private_endpoint.bigip_ple.private_service_connection[0].private_ip_address
  })
  filename                        = "${path.root}/work_tmp/tests.bash"
}
*/


