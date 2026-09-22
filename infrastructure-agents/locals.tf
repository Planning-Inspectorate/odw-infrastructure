locals {
  service_name = "odw"

  tags = merge(
    var.tags,
    {
      CreatedBy   = "Terraform"
      Environment = var.environment
      ServiceName = local.service_name
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
