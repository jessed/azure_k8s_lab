# Accept EULA
resource "azurerm_marketplace_agreement" "f5_bigip" {
  count                     = var.bigip.accept_eula == true ? 1 : 0
  publisher                 = var.bigip.publisher
  offer                     = var.bigip.use_paygo == true ? var.bigip.paygo-offer : var.bigip.byol-product
  plan                      = var.bigip.use_paygo == true ? var.bigip.paygo-plan : var.bigip.byol-plan
}

# Create bigip
resource "azurerm_linux_virtual_machine_scale_set" "bigip" {
  name                            = var.bigip.bigip_name
  computer_name_prefix            = var.bigip.node_prefix
  resource_group_name             = var.rg.name
  location                        = var.rg.location
  sku                             = var.bigip.size
  instances                       = var.bigip.nodes
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
    type                          = var.uai.id == "" ? "SystemAssigned" : "UserAssigned"
    identity_ids                  = var.uai.id == "" ? [""] : [var.uai.id]
  }

  admin_ssh_key {
    username                      = var.f5_common.bigip_user
    public_key                    = file(var.f5_common.public_key)
  }

  terminate_notification {
    enabled                       = var.bigip.use_terminate_notification
    timeout                       = var.bigip.terminate_wait_time
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
    storage_account_type          = var.bigip.disk
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
    enable_accelerated_networking = var.bigip.accel_net

    ip_configuration {
      name                        = "primary"
      primary                     = true
      subnet_id                   = var.data_subnet.id
      load_balancer_backend_address_pool_ids  = [ var.lb_pool.id ]
    }
  }
}

