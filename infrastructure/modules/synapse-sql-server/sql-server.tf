resource "azurerm_mssql_server" "sql_server" {
  #checkov:skip=CKV2_AZURE_45: Ensure Microsoft SQL server is configured with private endpoint (checkov v3)
  #checkov:skip=CKV2_AZURE_2: Ensure that Vulnerability Assessment (VA) is enabled on a SQL server by setting a Storage Account (checkov v3)
  #checkov:skip=CKV_AZURE_113: Firewall is enabled using azurerm_mssql_firewall_rule
  name                         = "sql-${local.resource_suffix}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  administrator_login          = var.sql_server_administrator_username
  administrator_login_password = random_password.sql_server_administrator_password.result
  version                      = "12.0"
  minimum_tls_version          = "1.2"

  azuread_administrator {
    azuread_authentication_only = false
    login_username              = var.sql_server_aad_administrator["username"]
    object_id                   = var.sql_server_aad_administrator["object_id"]
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}
