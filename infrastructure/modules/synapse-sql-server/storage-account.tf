resource "azurerm_storage_account" "sql_server_auditing" {
  #checkov:skip=CKV2_AZURE_40: Ensure storage account is not configured with Shared Key authorization (checkov v3)
  #checkov:skip=CKV2_AZURE_47: Ensure storage account is configured without blob anonymous access (checkov v3)
  #checkov:skip=CKV2_AZURE_41: Ensure storage account is configured with SAS expiration policy (checkov v3)
  #checkov:skip=CKV_AZURE_35: Firewall is enabled using azurerm_storage_account_network_rules
  #checkov:skip=CKV_AZURE_59: Firewall is enabled using azurerm_storage_account_network_rules
  #checkov:skip=CKV_AZURE_190: Firewall is enabled using azurerm_storage_account_network_rules
  #checkov:skip=CKV_AZURE_206: Locally redundant storage is acceptable for this storage account use-case
  #checkov:skip=CKV2_AZURE_1: Microsoft managed keys are acceptable
  #checkov:skip=CKV2_AZURE_8: Firewall is enabled using azurerm_storage_account_network_rules
  #checkov:skip=CKV2_AZURE_18: Microsoft managed keys are acceptable
  #checkov:skip=CKV2_AZURE_33: Private Endpoint is not enabled as networking is controlled by Firewall
  name                             = replace("pins-st-${local.resource_suffix}-${random_string.unique_id.id}", "-", "")
  location                         = var.location
  resource_group_name              = var.resource_group_name
  account_tier                     = "Premium"
  account_replication_type         = "LRS"
  account_kind                     = "BlockBlobStorage"
  default_to_oauth_authentication  = true
  https_traffic_only_enabled       = true
  min_tls_version                  = "TLS1_2"
  public_network_access_enabled    = true
  cross_tenant_replication_enabled = true

  blob_properties {
    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  tags = local.tags
}
