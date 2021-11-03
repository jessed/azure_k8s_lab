# F5 BIG-IP Azure Test/Performance Environment
## Overview
This Terraform plan will deploy an environment in which F5 BIG-IP performing transparent encryption 
of TCP traffic to a pre-defined server for decryption.

### Pre-deployment
Ensure you update variables in the following files prior to deployment:
- vars.tf
- v_vmss.auto.tfvars
- v_clients.auto.tfvars
- v_storage.auto.tfvars
- v_aks.auto.tfvars


## Modules
- resource_group
- network
- nsg
- log_analytics
- load-balancer
- pls
- user_assigned_identity
- vmss
- k8s
- clients
- vnet_peering

## Caveats / Notes
- The use of PAYGO vs BYOL licnsing is controlled by v_vmss.auto.tfvars: use_paygo
  - If BYOL licensing is used (use_paygo = true), the BIG-IQ variables in vars.tf populated.
- If the names of files to be retrieved (bigip.conf, iAppLX packages) begin with http or https the file is considered external and the file name will be treated like a URL.
  - Each filename is evaluated independently and treated accordingly.
  - If the file name does *not* begin with https/https the file will be retrieved from an Azure Secure Container.
  - The package assumes that a UserAssigned identity has been provided when retrieving data from a Secure Container.
  - The UserAssigned Identity should be specified in secrets.json:uai_name



### Common References
- Terraform [Azure Linux Scale Set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)
- [Virtual Machine Scale Set Scheduled Events](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-terminate-notification)
- [Azure Resource Manager (ARM) Templates](https://docs.microsoft.com/en-us/azure/templates/#arm-template-structure)

