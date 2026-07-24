locals {
  odt_nsips_back_office = {
    service_bus_name    = "pins-sb-back-office-${var.environment}-ukw-001"
    resource_group_name = "pins-rg-back-office-${var.environment}-ukw-001"
  }
  odt_nsips_back_office_service_bus_id = join("/", [
    "/subscriptions",
    var.odt_subscription_id,
    "resourceGroups",
    local.odt_nsips_back_office.resource_group_name,
    "providers/Microsoft.ServiceBus/namespaces",
    local.odt_nsips_back_office.service_bus_name
  ])

  odt_appeals_back_office = {
    resource_group_name  = "pins-rg-appeals-bo-${var.environment}"
    service_bus_enabled  = true
    service_bus_name     = "pins-sb-appeals-bo-${var.environment}"
    virtual_network_name = "pins-vnet-appeals-bo-${var.environment}"
  }
  odt_appeals_back_office_service_bus_id = join("/", [
    "/subscriptions",
    var.odt_subscription_id,
    "resourceGroups",
    local.odt_appeals_back_office.resource_group_name,
    "providers/Microsoft.ServiceBus/namespaces",
    local.odt_appeals_back_office.service_bus_name
  ])
}