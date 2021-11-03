clients = {
  bigip_ple_name          = "ple_bigip_client"
  vnet = {
    name                  = "jessnet-clients"
    cidr                  = "10.211.0.0/16"
  }
  node = {
    count                 = 1
    prefix                = "mvmc"
    domain                = "westus2.cloudapp.azure.com"
    user                  = "azadmin"
    public_ip_name        = "client_pub_ip"
    host_workdir          = "/tmp/cloud_init"
    image = {
      publisher           = "Canonical"
      offer               = "UbuntuServer"
      sku                 = "18.04-LTS"
      version             = "latest"
      disk                = "Standard_LRS"
      size                = "Standard_DS4_v2"
    }
  }
}
