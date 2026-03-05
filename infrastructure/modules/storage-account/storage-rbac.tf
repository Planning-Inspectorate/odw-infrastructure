resource "azurerm_role_assignment" "synapse_msi_data_lake" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.synapse_msi_id
}
