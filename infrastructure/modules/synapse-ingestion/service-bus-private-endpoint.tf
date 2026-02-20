resource "azurerm_private_endpoint" "odt_backoffice_servicebus_private_endpoint" {
  count = var.service_bus_premium_enabled ? 1 : 0

  name                = "pins-pe-sb-${local.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.synapse_private_endpoint_vnet_subnets[var.synapse_private_endpoint_subnet_name]
  private_service_connection {
    name                           = "pins-psc-sb-${local.resource_suffix}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_servicebus_namespace.synapse.id
    subresource_names              = ["namespace"]
  }

  tags = local.tags
}
