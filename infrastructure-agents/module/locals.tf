locals {
  module_name = "devops-agents"

  short_location  = var.location == "UK South" ? "uks" : "ukw"
  resource_suffix = "${var.service_name}-${var.environment}-${local.short_location}"

  tags = merge(
    var.tags,
    {
      ModuleName = local.module_name
    }
  )
}
