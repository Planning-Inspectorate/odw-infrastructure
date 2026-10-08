data "azurerm_mssql_server" "crown_training" {
  count = var.environment == "test" || var.environment == "prod" ? 1 : 0

  provider = azurerm.training

  name                = "pins-sql-crown-primary-training"
  resource_group_name = "pins-rg-crown-training"
}