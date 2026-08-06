locals {
  module_name     = "devops-agents"
  resource_suffix = "${var.service_name}-${var.environment}-${module.azure_region.location_short}"

  tags = merge(
    var.tags,
    {
      ModuleName = local.module_name
    },
    var.environment == "prod" ? {
      SystemAssetOwner    = var.system_asset_owner
      BusinessProcess     = "ODW"
      PersonalData        = "No"
      SpecialCategoryData = "No"
      ProtectiveMarking   = "Official-Sensitive-Mission-Critical"
      CriticalityRating   = "Level 2"
    } : {}
  )
}
