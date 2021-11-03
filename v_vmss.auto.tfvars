# VMSS Setup
vmss = {
  prefix                      = "mvmltm"
  nodes                       = 2
  domain                      = "westus2.cloudapp.azure.com"
  disk                        = "Standard_LRS"
  dns_server                  = "168.63.129.16"
  ntp_server                  = "tick.ucla.edu"
  timezone                    = "America/Los_Angeles"
  mgmt_port                   = "443"
  mgmt_ip_pub                 = "bigip_mgmt_pub"
  mgmt_ip_name                = "bigip_mgmt"
  data_ip_pub                 = "bigip_data_pub"
  data_ip_name                = "bigip_data"
  accel_net                   = false                           # Accelerated Networking (Only image w/ 4+ vCPU)
  use_paygo                   = true
  use_terminate_notification  = false
  terminate_wait_time         = "PT5M"


# storage account for boot diagnostics
  storage_name                = "jessemvmdiagnostics"
  boot_diagnostics_enabled    = false

## Marketplace general
  # Generates an error if enabled with BYOL images, or if the license for a paygo image has previously 
  # been accepted. Basically, this is a single-use item for each BIG-IP image. 
  accept_eula                 = false                                  # Accept marketplace aggreement

  publisher                   = "f5-networks"
  f5ver                       = "16.1.000000"
  size                        = "Standard_DS3_v2"

## BYOL Images
  byol-plan                   = "f5-big-all-2slot-byol"                # sku:     BYOL
  byol-sku                    = "f5-big-all-2slot-byol"                # sku:     BYOL
  byol-offer                  = "f5-big-ip-byol"                       # offer:   BYOL
  byol-product                = "f5-big-ip-byol"                       # offer:   BYOL

## PAYG Images
  paygo-plan                  = "f5-bigip-virtual-edition-1g-good-hourly"     # sku:     PAYG, 1G, Good
  paygo-sku                   = "f5-bigip-virtual-edition-1g-good-hourly"     # sku:     PAYG, 1G, Good
  paygo-offer                 = "f5-big-ip-good"                              # offer:   PAYG, Good
  paygo-product               = "f5-big-ip-good"                              # offer:   PAYG, Good
}
