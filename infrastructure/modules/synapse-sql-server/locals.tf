locals {
  module_name     = "synapse-sql-server"
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

  # ODW env -> which MPESC/PEAS SQL env to target
  mpesc_target_env = {
    dev  = "dev"
    prod = "training" # ODW prod connects to MPESC staging/training
  }

  mpesc_sql_server_ids = {
    dev      = "/subscriptions/962e477c-0f3b-4372-97fc-a198a58e259e/resourceGroups/pins-rg-peas-dev/providers/Microsoft.Sql/servers/pins-sql-peas-primary-dev"
    training = "/subscriptions/dbfbfbbf-eb6f-457b-9c0c-fe3a071975bc/resourceGroups/pins-rg-peas-training/providers/Microsoft.Sql/servers/pins-sql-peas-primary-training"
  }

  mpesc_sql_target_resource_id = local.mpesc_sql_server_ids[local.mpesc_target_env[var.environment]]

}
