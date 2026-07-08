data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "azurerm_private_dns_zone" "storage" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.tooling_config.network_rg

  provider = azurerm.tooling
}
 