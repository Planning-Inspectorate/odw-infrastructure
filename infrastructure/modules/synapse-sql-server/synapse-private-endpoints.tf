resource "azurerm_synapse_managed_private_endpoint" "data_lake" {
  name                 = "synapse-sql-sqlServer--${azurerm_mssql_server.sql_server.name}"
  synapse_workspace_id = var.synapse_workspace_id
  target_resource_id   = azurerm_mssql_server.sql_server.id
  subresource_name     = "sqlServer"
}

resource "azurerm_synapse_managed_private_endpoint" "cbos_sql_dev" {
  count                = var.environment == "dev" ? 1 : 0
  name                 = "synapse-cbos-sqlserver-dev-peas"
  synapse_workspace_id = var.synapse_workspace_id
  target_resource_id   = "/subscriptions/962e477c-0f3b-4372-97fc-a198a58e259e/resourceGroups/pins-rg-peas-dev/providers/Microsoft.Sql/servers/pins-sql-peas-primary-dev"
  subresource_name     = "sqlServer"
}