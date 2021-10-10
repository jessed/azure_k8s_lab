# VMSS Setup
vmss = {
  prefix                  = "mvmltm"
  nodes                   = 2
  domain                  = "westus2.cloudapp.azure.com"
  disk                    = "Standard_LRS"
  dns_server              = "168.63.129.16"
  ntp_server              = "tick.ucla.edu"
  timezone                = "America/Los_Angeles"
  mgmt_port               = "443"
  mgmt_ip_pub             = "bigip_mgmt_pub"
  mgmt_ip_name            = "bigip_mgmt"
  data_ip_pub             = "bigip_data_pub"
  data_ip_name            = "bigip_data"
  accel_net               = false                                    # Accelerated Networking (Only image w/ 4+ vCPU)


# storage account for boot diagnostics
  storage_name            = "jessemvmdiagnostics"

## Marketplace general
  # Generates an error if enabled with BYOL images
  accept_eula             = false                                  # Accept marketplace aggreement
  publisher               = "f5-networks"
#  f5ver                   = "15.1.201000"
  f5ver                   = "16.1.000000"
  size                    = "Standard_DS3_v2"

## BYOL Images
#  plan                    = "f5-big-all-2slot-byol"                # sku:     BYOL
#  sku                     = "f5-big-all-2slot-byol"                # sku:     BYOL
#  offer                   = "f5-big-ip-byol"                       # offer:   BYOL
#  product                 = "f5-big-ip-byol"                       # offer:   BYOL

## PAYG Images
  plan                    = "f5-bigip-virtual-edition-1g-good-hourly"     # sku:     PAYG, 1G, Good
  sku                     = "f5-bigip-virtual-edition-1g-good-hourly"     # sku:     PAYG, 1G, Good
  offer                   = "f5-big-ip-good"                              # offer:   PAYG, Good
  product                 = "f5-big-ip-good"                              # offer:   PAYG, Good
  paygo_image             = true
}
