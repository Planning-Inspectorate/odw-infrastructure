# --- Checkmark Managed Identity (THEODW-3486) ---
# Dedicated, environment-specific user-assigned Managed Identity used by the Checkmark
# application to authenticate to ODW curated data without shared credentials. The
# object ID output below is shared with the ODW team to add as an external login/user
# in Synapse (via CREATE USER ... FROM EXTERNAL PROVIDER) in a subsequent story.

resource "azurerm_user_assigned_identity" "checkmark" {
  count = var.checkmark_managed_identity_enabled ? 1 : 0

  name                = "pins-id-checkmark-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.data_management.name
  location            = module.azure_region.location_cli

  tags = local.tags
}
