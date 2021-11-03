
data "azurerm_subscription" "primary"  {}
data "azurerm_client_config" "client"  {}

# Create new UAI
resource "azurerm_user_assigned_identity" "uai" {
  resource_group_name             = var.rg.name
  location                        = var.rg.location
  name                            = var.uai_name
}


# Create role definition - storage blob reader
resource "azurerm_role_definition" "blob_reader" {
  name                            = format("%s-bigip_blob_reader", var.rg.name)
  scope                           = data.azurerm_subscription.primary.id
  description                     = "Custom role to read ltm_config container"

  permissions {
    actions       = [ "Microsoft.Storage/storageAccounts/blobServices/containers/read",
                      "Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action",
                      "Microsoft.Storage/storageAccounts/listKeys/action",
                      "Microsoft.Storage/storageAccounts/read",
                      "Microsoft.Storage/storageAccounts/listAccountSas/action",

                    ]
    data_actions  = [ "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
                    ]
  }

  assignable_scopes = [
    var.storage.account.id
  ]
}

# Create role definition - VMSS changes
resource "azurerm_role_definition" "vmss_auto" {
  name                            = format("%s-bigip_vmss_auto", var.rg.name)
  scope                           = data.azurerm_subscription.primary.id
  description                     = "Custom role to redeploy a VMSS instance in the event of cloud-init failure"

  permissions {
    actions       = [ 
                      "Microsoft.Compute/virtualMachineScaleSets/*",
                      "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/*",
                    ]
  }

  assignable_scopes = [
    var.rg.id
  ]
}

# Assign blob reader role
resource "azurerm_role_assignment" "uai_blob_reader" {
  scope                           = var.storage.account.id
  role_definition_id              = azurerm_role_definition.blob_reader.role_definition_resource_id
  principal_id                    = azurerm_user_assigned_identity.uai.principal_id

  # work-around: https://github.com/hashicorp/terraform-provider-azurerm/issues/4258
  #role_definition_id              = "${data.azurerm_subscription.primary.id}/providers/Microsoft.Authorization/roleDefinitions/${azurerm_role_definition.blob_reader.id}"
}


# Assign vmss change role
resource "azurerm_role_assignment" "uai_vmss_modify" {
  scope                           = var.rg.id
  role_definition_id              = azurerm_role_definition.vmss_auto.role_definition_resource_id
  principal_id                    = azurerm_user_assigned_identity.uai.principal_id
}


