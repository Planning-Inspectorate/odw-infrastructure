# =============================================================================
# SAP BTP OAuth Authentication (THEODW-3387)
#
# Provides an Entra ID App Registration + Service Principal that MHCLG's SAP
# BTP tenant uses to obtain an OAuth 2.0 token, then authenticates to the SAP
# landing storage account (workload-sap-btp.tf) with `Storage Blob Data
# Contributor` RBAC.
#
# The client secret is rotated every 180 days via `time_rotating` and stored
# alongside the client ID in the ODW Key Vault so ops can retrieve the current
# value without hitting the Terraform state.
#
# Consumer (MHCLG/SAP) handover fields:
#   - Tenant ID              (output: sap_btp_tenant_id)
#   - Application/Client ID  (output: sap_btp_client_id)
#   - Token endpoint         (output: sap_btp_token_endpoint)
#   - Client secret          (Key Vault: sap-btp-client-secret)
#
# All resources are gated on `var.deploy_sap_btp_landing` for parity with the
# rest of the SAP-BTP stack.
# =============================================================================

# -----------------------------------------------------------------------------
# App Registration + Service Principal
# -----------------------------------------------------------------------------
resource "azuread_application" "sap_btp" {
  count = var.deploy_sap_btp_landing ? 1 : 0

  display_name     = "pins-app-odw-sap-${var.environment}"
  owners           = [data.azurerm_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

  notes = "App Registration for MHCLG SAP BTP to ingest data into PINS ODW landing storage over Private Link (THEODW-3387)."
}

resource "azuread_service_principal" "sap_btp" {
  count = var.deploy_sap_btp_landing ? 1 : 0

  client_id                    = azuread_application.sap_btp[0].client_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
}

# -----------------------------------------------------------------------------
# Client Secret with 180-day rotation
# -----------------------------------------------------------------------------
resource "time_rotating" "sap_btp_secret_rotation" {
  count = var.deploy_sap_btp_landing ? 1 : 0

  rotation_days = 180
}

resource "azuread_application_password" "sap_btp" {
  count = var.deploy_sap_btp_landing ? 1 : 0

  application_id = azuread_application.sap_btp[0].id
  display_name   = "sap-btp-client-secret-${var.environment}"
  end_date       = time_rotating.sap_btp_secret_rotation[0].rotation_rfc3339

  rotate_when_changed = {
    rotation = time_rotating.sap_btp_secret_rotation[0].id
  }
}

# -----------------------------------------------------------------------------
# Key Vault storage of credentials
# -----------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "sap_btp_client_id" {
  count = var.deploy_sap_btp_landing ? 1 : 0

  name         = "sap-btp-client-id"
  value        = azuread_application.sap_btp[0].client_id
  key_vault_id = module.synapse_data_lake.key_vault_id
  content_type = "text/plain"
  tags         = local.tags
}

resource "azurerm_key_vault_secret" "sap_btp_client_secret" {
  count = var.deploy_sap_btp_landing ? 1 : 0

  name            = "sap-btp-client-secret"
  value           = azuread_application_password.sap_btp[0].value
  key_vault_id    = module.synapse_data_lake.key_vault_id
  content_type    = "text/plain"
  expiration_date = azuread_application_password.sap_btp[0].end_date
  tags            = local.tags
}

resource "azurerm_key_vault_secret" "sap_btp_tenant_id" {
  count = var.deploy_sap_btp_landing ? 1 : 0

  name         = "sap-btp-tenant-id"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = module.synapse_data_lake.key_vault_id
  content_type = "text/plain"
  tags         = local.tags
}

# -----------------------------------------------------------------------------
# RBAC: Storage Blob Data Contributor scoped to the SAP landing storage account
# -----------------------------------------------------------------------------
resource "azurerm_role_assignment" "sap_btp_blob_contributor" {
  count = var.deploy_sap_btp_landing ? 1 : 0

  scope                = module.storage_account_sap_landing[0].storage_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.sap_btp[0].object_id
}

