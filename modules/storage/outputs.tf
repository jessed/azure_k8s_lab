output "out"     {
  value = {
    account     = azurerm_storage_account.primary
    container   = azurerm_storage_container.container
  }
}
