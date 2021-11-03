# Accept EULA
resource "azurerm_marketplace_agreement" "f5_bigip" {
  count                     = var.vmss.accept_eula == true ? 1 : 0
  publisher                 = var.vmss.publisher
  offer                     = var.vmss.use_paygo == true ? var.vmss.paygo-offer : var.vmss.byol-product
  plan                      = var.vmss.use_paygo == true ? var.vmss.paygo-plan : var.vmss.byol-plan
}

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

  # Uncomment to enable boot diagnostics
#  boot_diagnostics {
#    storage_account_uri           = var.storage.primary_blob_endpoint
#  }

  # A valid identity name must be provided in secrets.json
  identity {
    type                          = var.uai.id != "" ? "UserAssigned" : "SystemAssigned"
    identity_ids                  = var.uai.id != "" ? [var.uai.id] : [""]
  }

  admin_ssh_key {
    username                      = var.f5_common.bigip_user
    public_key                    = file(var.f5_common.public_key)
  }

  terminate_notification {
    enabled                       = var.vmss.use_terminate_notification
    timeout                       = var.vmss.terminate_wait_time
  }

  source_image_reference {
    publisher                     = var.vmss.publisher
    version                       = var.vmss.f5ver
    offer                         = var.vmss.use_paygo == true ? var.vmss.paygo-product : var.vmss.byol-product
    sku                           = var.vmss.use_paygo == true ? var.vmss.paygo-sku : var.vmss.byol-sku
  }

  plan {
    publisher                     = var.vmss.publisher
    product                       = var.vmss.use_paygo == true ? var.vmss.paygo-product : var.vmss.byol-product
    name                          = var.vmss.use_paygo == true ? var.vmss.paygo-sku : var.vmss.byol-sku
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
    enable_accelerated_networking = var.vmss.accel_net

    ip_configuration {
      name                        = "primary"
      primary                     = true
      subnet_id                   = var.data_subnet.id
      load_balancer_backend_address_pool_ids  = [ var.lb_pool.id ]
    }
  }
}

