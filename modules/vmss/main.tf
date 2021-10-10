# Create VMSS and associated components


/*
# Create storage account for boot diagnostics
resource "azurerm_storage_account" "vmss_storage" {
  name                            = var.vmss.storage_name
  resource_group_name             = var.rg.name
  location                        = var.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
}
*/


# Create VMSS
resource "azurerm_linux_virtual_machine_scale_set" "bigip" {
  name                            = var.vmss.prefix
  computer_name_prefix            = var.vmss.prefix
  resource_group_name             = var.rg.name
  location                        = var.rg.location
  sku                             = var.vmss.size
  instances                       = var.vmss.nodes
  overprovision                   = false
  provision_vm_agent              = false
  admin_username                  = var.f5_common.bigip_user
  custom_data                     = base64encode(local_file.bigip_onboard.content)

#  boot_diagnostics {
#    storage_account_uri           = azurerm_storage_account.vmss_storage.primary_blob_endpoint
#  }

  admin_ssh_key {
    username                      = var.f5_common.bigip_user
    public_key                    = file(var.f5_common.public_key)
  }

  terminate_notification {
    enabled                       = true
    timeout                       = "PT10M"
  }

  source_image_reference {
    publisher                     = var.vmss.publisher
    offer                         = var.vmss.product
    sku                           = var.vmss.sku
    version                       = var.vmss.f5ver
  }

  plan {
    publisher                     = var.vmss.publisher
    product                       = var.vmss.product
    name                          = var.vmss.sku
  }

  os_disk {
    storage_account_type          = var.vmss.disk
    caching                       = "ReadWrite"
  }

  network_interface {
    name                          = "mgmt"
    primary                       = true
    network_security_group_id     = var.mgmt_nsg.id

    ip_configuration {
      name                        = "primary"
      primary                     = true
      subnet_id                   = var.mgmt_subnet.id
      public_ip_address {
        name                      = "pub_mgmt"
      }
    }
  }
  network_interface {
    name                          = "data"
    primary                       = false
    network_security_group_id     = var.data_nsg.id
    enable_accelerated_networking = true

    ip_configuration {
      name                        = "primary"
      primary                     = true
      subnet_id                   = var.data_subnet.id
      load_balancer_backend_address_pool_ids  = [ var.lb_pool.id ]
    }
  }
}

