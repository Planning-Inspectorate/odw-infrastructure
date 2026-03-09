locals {
  module_name     = "synapse-workspace-private"
  resource_suffix = "${var.service_name}-${var.environment}-${module.azure_region.location_short}"

  firewall_allowed_ip_addresses = [
    for address in var.firewall_allowed_ip_addresses : can(split("/", address)[1]) ? address : "${address}/32"
  ]

  tags = merge(
    var.tags,
    {
      ModuleName = local.module_name
    }
  )

  cbos_sql_mpe = var.environment == "dev" ? {
    dev = {
      name               = "synapse-cbos-sqlserver-dev-peas"
      target_resource_id = "/subscriptions/962e477c-0f3b-4372-97fc-a198a58e259e/resourceGroups/pins-rg-peas-dev/providers/Microsoft.Sql/servers/pins-sql-peas-primary-dev"
    }
    } : var.environment == "prod" ? {
    prod = {
      name               = "synapse-cbos-sqlserver-prod-training-peas"
      target_resource_id = "/subscriptions/dbfbfbbf-eb6f-457b-9c0c-fe3a071975bc/resourceGroups/pins-rg-peas-training/providers/Microsoft.Sql/servers/pins-sql-peas-primary-training"
    }
  } : {}
}
