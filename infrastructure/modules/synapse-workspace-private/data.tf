data "azurerm_mssql_server" "crown_training" {
  provider = azurerm.odt

  name                = "pins-sql-crown-primary-${var.environment}"
  resource_group_name = "pins-rg-crown-${var.environment}"
}