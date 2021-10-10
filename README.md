# F5 BIG-IP Azure Test/Performance Environment
## Overview
This Terraform plan will deploy an environment in which F5 BIG-IP performing transparent encryption 
of TCP traffic to a pre-defined server for decryption.

### Pre-deployment
Ensure you update variables in the following files prior to deployment:
- vars.tf
- v_clients.auto.tfvars
- v_vmss.auto.tfvars
- v_bigip.auto.tfvars
- v_k8s.auto.tfvars

**IMPORTANT**
To use this Terraform Plan you must install the 'aks-preview' az extension and register to preview features.

- az extension add --name aks-preview
-- If already present, use "az extension update --name aks-preview"
- az feature register --namespace "Microsoft.ContainerService" --name "CustomNodeConfigPreview"
- az feature register --namespace "Microsoft.ContainerService" --name "PodSubnetPreview"
- az provider register -n Microsoft.ContainerService


## Modules
- resource_group
- network
- nsg
- bigiq_ple
- log_analytics
- load-balancer
- pls
- user_assigned_identity
- vmss
- clients
- servers
- vnet_peering

## Caveats



