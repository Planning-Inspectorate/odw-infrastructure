resource "azurerm_role_assignment" "synapse_msi_data_lake" {
  count                = var.synapse_msi_id != null ? 1 : 0
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.synapse_msi_id
}
