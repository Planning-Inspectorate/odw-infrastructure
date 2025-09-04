
resource "azurerm_role_assignment" "synapse_msi_purview_unified_catalog_storage" {
  scope                = var.purview_unified_catalog_storage
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.synapse.identity[0].principal_id
}
