# --- SAP BTP Storage Landing Zone (THEODW-3386) ---

resource "azurerm_storage_account" "sap_landing" {
  # Name will be pinsstsaplandingdevuks (22 chars)
  name                     = "pinsstsaplanding${var.environment}${module.azure_region.location_short}"
  resource_group_name      = data.azurerm_resource_group.data.name
  location                 = data.azurerm_resource_group.data.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Standard Blob for SAP compatibility as per PoC design
  is_hns_enabled           = false

  # Security Requirements
  public_network_access_enabled = false
  enable_https_traffic_only     = true
  min_tls_version               = "TLS1_2"

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  tags = merge(local.tags, {
    Project = "SAP-BTP-PoC"
  })
}

resource "azurerm_storage_container" "sap_container" {
  name                  = "sap-test-entity"
  storage_account_id    = azurerm_storage_account.sap_landing.id
  container_access_type = "private"
}