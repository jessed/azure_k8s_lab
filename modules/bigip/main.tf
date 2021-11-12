# Accept the marketplace EULA
resource "azurerm_marketplace_agreement" "f5_bigip" {
  count                     = var.bigip.accept_eula == true ? 1 : 0
  publisher                 = var.bigip.publisher
  offer                     = var.bigip.use_paygo == true ? var.bigip.paygo-offer : var.bigip.byol-product
  plan                      = var.bigip.use_paygo == true ? var.bigip.paygo-plan : var.bigip.byol-plan
}

# Create Public IP(s)
resource "azurerm_public_ip" "mgmt_pub_ip" {
  count                           = var.bigip.nodes
  name                            = format("${var.bigip.node_prefix}%02d_mgmt_pub_ip", count.index+1)
  location                        = var.rg.location
  resource_group_name             = var.rg.name
  allocation_method               = "Static"
  sku                             = "Standard"
}
resource "azurerm_public_ip" "data_pub_ip" {
  count                           = var.bigip.nodes
  name                            = format("${var.bigip.node_prefix}%02d_data_pub_ip", count.index+1)
  location                        = var.rg.location
  resource_group_name             = var.rg.name
  allocation_method               = "Static"
  sku                             = "Standard"
}

# Create NICs
# mgmt
resource "azurerm_network_interface" "mgmt_nic" {
  count                           = var.bigip.nodes
  name                            = format("${var.bigip.node_prefix}%02d_mgmt_nic", count.index+1)
  location                        = var.rg.location
  resource_group_name             = var.rg.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.mgmt_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mgmt_pub_ip.*.id[count.index]
  }
  timeouts {
    update = "10m"
    delete = "10m"
  }
}

# data-plane 
resource "azurerm_network_interface" "data_nic" {
  count                           = var.bigip.nodes
  name                            = format("${var.bigip.node_prefix}%02d_data_nic", count.index+1)
  location                        = var.rg.location
  resource_group_name             = var.rg.name
  enable_ip_forwarding            = true
  enable_accelerated_networking   = var.bigip.accel_net

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.data_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.data_pub_ip.*.id[count.index]
  }
  timeouts {
    update = "10m"
    delete = "10m"
  }
}

# Associate data-plane address with ILB backend pool
resource "azurerm_network_interface_backend_address_pool_association" "lb" {
  count                           = var.bigip.nodes
  network_interface_id            = azurerm_network_interface.data_nic.*.id[count.index]
  ip_configuration_name           = "primary"
  backend_address_pool_id         = var.lb_pool.id
}

# Associate NSG with NICs
resource "azurerm_network_interface_security_group_association" "mgmt_sec" {
  count                           = var.bigip.nodes
  network_interface_id            = azurerm_network_interface.mgmt_nic.*.id[count.index]
  network_security_group_id       = var.mgmt_nsg.id
}
resource "azurerm_network_interface_security_group_association" "data_sec" {
  count                           = var.bigip.nodes
  network_interface_id            = azurerm_network_interface.data_nic.*.id[count.index]
  network_security_group_id       = var.data_nsg.id
}

resource "azurerm_linux_virtual_machine" "bigip" {
  count                           = var.bigip.nodes
  name                            = format("${var.bigip.node_prefix}%02d", count.index+1)
  computer_name                   = format("${var.bigip.node_prefix}%02d.${var.bigip.domain}", count.index+1)
  location                        = var.rg.location
  resource_group_name             = var.rg.name
  admin_username                  = var.f5_common.bigip_user
  admin_password                  = var.f5_common.bigip_pass
  size                            = var.bigip.size
  disable_password_authentication = true 
  custom_data                     = base64encode(local_file.bigip_onboard.content)
  network_interface_ids           = [
                                     azurerm_network_interface.mgmt_nic.*.id[count.index],
                                     azurerm_network_interface.data_nic.*.id[count.index]
                                    ]

  admin_ssh_key {
    username                      = var.f5_common.bigip_user
    public_key                    = file(var.f5_common.public_key)
  }

  # A valid identity name must be provided in secrets.json
  identity {
    type                          = var.uai.id == "" ? "SystemAssigned" : "UserAssigned"
    identity_ids                  = var.uai.id == "" ? [""] : [var.uai.id]
  }

  source_image_reference {
    publisher                     = var.bigip.publisher
    version                       = var.bigip.f5ver
    offer                         = var.bigip.use_paygo == true ? var.bigip.paygo-product : var.bigip.byol-product
    sku                           = var.bigip.use_paygo == true ? var.bigip.paygo-sku : var.bigip.byol-sku 
  }

  plan {
    publisher                     = var.bigip.publisher
    product                       = var.bigip.use_paygo == true ? var.bigip.paygo-product : var.bigip.byol-product
    name                          = var.bigip.use_paygo == true ? var.bigip.paygo-sku : var.bigip.byol-sku
  }

  os_disk {
    name                          = format("${var.bigip.node_prefix}%02d_disk", count.index+1)
    storage_account_type          = var.bigip.disk
    caching                       = "ReadWrite"
  }

  timeouts {
    update = "10m"
    delete = "10m"
  }

  # Update local hosts file with this bigip address
  provisioner "local-exec" {
    command       = "${path.root}/scripts/update_hosts.bash ${self.name} ${self.public_ip_address}"
  }
}

/*
resource "null_resource" "revoke_license" {
  count                           = var.bigip.nodes
  triggers  = {
    host                          = azurerm_linux_virtual_machine.bigip[count.index].public_ip_address
  }

  # Deprecated; not necessary when 'provider.azurerm.virtual_machine.graceful_shutdown == true'
  provisioner "local-exec" {
    when                          = destroy
    command                       = "${path.root}/scripts/revoke_license.bash ${self.triggers.host}"
  }
}
*/
