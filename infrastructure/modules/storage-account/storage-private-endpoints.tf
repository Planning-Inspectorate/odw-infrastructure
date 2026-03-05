# private endpoints in tooling
locals {
  storage_zones = ["blob", "table"]
}

resource "azurerm_private_endpoint" "storage" {
  for_each = toset(local.storage_zones)

  name                = "pins-pe-${each.key}-tooling-${local.resource_suffix}-${random_string.unique_id.id}"
  resource_group_name = var.network_resource_group_name
  location            = var.location
  subnet_id           = var.vnet_subnet_ids[var.synapse_private_endpoint_subnet_name]

  private_dns_zone_group {
    name                 = "storagePrivateDnsZone${each.key}"
    private_dns_zone_ids = [var.tooling_config.storage_private_dns_zone_id[each.key]]
  }

  private_service_connection {
    name                           = "storagePrivateServiceConnection${each.key}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = [each.key]
  }

  tags = local.tags
}