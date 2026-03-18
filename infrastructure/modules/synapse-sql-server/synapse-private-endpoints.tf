resource "azurerm_synapse_managed_private_endpoint" "data_lake" {
  name                 = "synapse-sql-sqlServer--${azurerm_mssql_server.sql_server.name}"
  synapse_workspace_id = var.synapse_workspace_id
  target_resource_id   = azurerm_mssql_server.sql_server.id
  subresource_name     = "sqlServer"
}


resource "azurerm_synapse_managed_private_endpoint" "mpesc_prod_sql" {
  count = var.environment == "prod" ? 1 : 0

  name                 = "synapse-sql-sqlServer--pins-sql-peas-primary-prod"
  synapse_workspace_id = var.synapse_workspace_id
  target_resource_id   = "/subscriptions/d1d6c393-2fe3-40af-ac27-f5b6bad36735/resourceGroups/pins-rg-peas-prod/providers/Microsoft.Sql/servers/pins-sql-peas-primary-prod"
  subresource_name     = "sqlServer"
}