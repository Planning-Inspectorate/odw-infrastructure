locals {
  module_name     = "devops-agents"
  resource_suffix = "${var.service_name}-${var.environment}-${module.azure_region.location_short}"

  tags = merge(
    var.tags,
    {
      ModuleName = local.module_name
    }
  )

  dns_servers = var.environment == "prod" ? ["192.168.5.4", "192.168.5.10", "168.63.129.16"] : []
}
