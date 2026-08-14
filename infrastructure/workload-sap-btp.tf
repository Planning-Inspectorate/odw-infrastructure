# --- SAP BTP Storage Landing Zone (THEODW-3386) ---

resource "azurerm_storage_account" "sap_landing" {
  #checkov:skip=CKV_AZURE_33: Queue logging IS enabled — via the separate azurerm_storage_account_queue_properties.sap_landing resource below (matching the pattern used in modules/synapse-shir). Checkov's attribute check only inspects the inline queue_properties block on azurerm_storage_account, so this is a false-positive suppression, not a policy waiver.
  #checkov:skip=CKV2_AZURE_1: PoC uses Microsoft-managed keys; CMK via the standard ODW Key Vault (pinskvsynwodw<env>uks) to be introduced pre-production (THEODW-3387 follow-up).
  #checkov:skip=CKV2_AZURE_18: PoC uses Microsoft-managed keys; CMK via the standard ODW Key Vault (pinskvsynwodw<env>uks) to be introduced pre-production (THEODW-3387 follow-up).
  #checkov:skip=CKV2_AZURE_33: Public network access is disabled and firewall denies by default. Private Endpoint + Private Link Service bridge to SAP BTP is delivered under THEODW-3385; drop this skip once implemented.
  #checkov:skip=CKV2_AZURE_40: Shared Key auth required for the PoC because SAP BTP Cloud Integration Destinations currently consume account-key-based SAS URLs. Target state (THEODW-3387) is OAuth via Entra ID App Registration — drop this skip and set shared_access_key_enabled = false once the OAuth flow is validated with MHCLG.
  #checkov:skip=CKV2_AZURE_41: SAS expiration policy IS configured via the sas_policy block below (1-day expiration, Log action). Checkov 3.2.529 does not always detect it on this layout — skip is a false-positive suppression, not a policy waiver.

  # Name: pinsstsapldngdevuks (19 chars) - safe for all environment lengths
  name                = "pinsstsapldng${var.environment}${module.azure_region.location_short}"
  resource_group_name = azurerm_resource_group.data.name
  location            = azurerm_resource_group.data.location

  account_tier             = "Standard"
  account_replication_type = "GZRS"

  # Standard Blob (non-HNS) for SAP compatibility as per PoC design
  is_hns_enabled = false

  # Security hardening
  public_network_access_enabled   = false
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  local_user_enabled              = false

  sas_policy {
    expiration_period = "01.00:00:00"
    expiration_action = "Log"
  }

  blob_properties {
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 30
    }
  }

  tags = merge(local.tags, {
    Project = "SAP-BTP-PoC"
  })
}

# Firewall / network rules defined as a separate resource so Checkov recognises
# network restrictions (CKV_AZURE_35 / 59 / 190 and CKV2_AZURE_8).
resource "azurerm_storage_account_network_rules" "sap_landing" {
  storage_account_id = azurerm_storage_account.sap_landing.id
  default_action     = "Deny"
  bypass             = ["AzureServices"]
}

# Queue service logging – satisfies CKV_AZURE_33. No queues are used by the SAP
# BTP integration today, but enabling logging is cheap defence-in-depth and
# keeps the security baseline consistent with other ODW storage accounts.
resource "azurerm_storage_account_queue_properties" "sap_landing" {
  storage_account_id = azurerm_storage_account.sap_landing.id

  logging {
    read                  = true
    write                 = true
    delete                = true
    retention_policy_days = 7
    version               = "1.0"
  }

  minute_metrics {
    include_apis          = true
    retention_policy_days = 7
    version               = "1.0"
  }

  hour_metrics {
    include_apis          = true
    retention_policy_days = 7
    version               = "1.0"
  }
}

resource "azurerm_storage_container" "sap_container" {
  #checkov:skip=CKV2_AZURE_21: Blob read logging is provided centrally via diagnostic settings / Azure Policy at the subscription level
  name                  = "sap-test-entity"
  storage_account_id    = azurerm_storage_account.sap_landing.id
  container_access_type = "private"
}
