resource "azurerm_storage_account_network_rules" "synapse" {
  storage_account_id         = azurerm_storage_account.synapse.id
  default_action             = "Deny"
  bypass                     = ["AzureServices", "Metrics", "Logging"]
  ip_rules                   = var.firewall_allowed_ip_addresses
  virtual_network_subnet_ids = local.azurerm_synapse_vnet_subnet_ids

  dynamic "private_link_access" {
    for_each = var.defender_private_link_access

    content {
      endpoint_resource_id = private_link_access.value.endpoint_resource_id
      endpoint_tenant_id   = private_link_access.value.endpoint_tenant_id
    }
  }
}

# read Horizon Subnet Ids
data "azurerm_subnet" "horizon_database" {
  count                = var.external_resource_links_enabled ? 1 : 0
  name                 = var.horizon_integration_config.networking.database_subnet_name
  virtual_network_name = var.horizon_integration_config.networking.vnet_name
  resource_group_name  = var.horizon_integration_config.networking.resource_group_name

  provider = azurerm.horizon
}
