resource "azurerm_synapse_managed_private_endpoint" "data_lake" {
  name                 = "synapse-sql-sqlServer--${azurerm_mssql_server.sql_server.name}"
  synapse_workspace_id = var.synapse_workspace_id
  target_resource_id   = azurerm_mssql_server.sql_server.id
  subresource_name     = "sqlServer"
}

resource "azurerm_synapse_managed_private_endpoint" "cbos_sql" {
  name                 = "synapse-cbos-sqlserver-${var.environment}-peas"
  synapse_workspace_id = var.synapse_workspace_id
  target_resource_id   = local.mpesc_sql_target_resource_id
  subresource_name     = "sqlServer"
}