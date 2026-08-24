# --- SAP BTP Storage Landing Zone (THEODW-3386) ---

module "storage_account_sap_landing" {
  count = var.deploy_sap_btp_landing ? 1 : 0

  source = "./modules/storage-account"

  resource_group_name = azurerm_resource_group.data.name
  service_name        = "sapldg" # 6 chars keeps storage account name within 24-char Azure limit
  environment         = var.environment
  location            = module.azure_region.location_cli
  tags                = local.tags

  # Configuration - LRS aligns with ODW module defaults and cost-saving patterns.
  storage_replication = "LRS"
  is_hns_enabled      = false
  container_name      = ["sap-test-entity"]

  # Network Rules: allow access from ODW compute and function subnets so
  # in-VNet workloads (and the SAP proxy VMSS) can reach the account. The
  # module sets default_action = Deny by default.
  network_rule_virtual_network_subnet_ids = [
    module.synapse_network.vnet_subnets[local.compute_subnet_name],
    module.synapse_network.vnet_subnets[local.functionapp_subnet_name]
  ]
}

# --- Networking Bridge (THEODW-3386) ---

# Private Endpoint for Blob access - required because public access is denied
# on the storage account. Placed in the ODW network RG and compute subnet,
# mirroring workload-s62a.tf.
resource "azurerm_private_endpoint" "sap_landing_blob_endpoint" {
  count = var.deploy_sap_btp_landing ? 1 : 0

  name                = "pins-pe-odw-sap-blob-${var.environment}"
  resource_group_name = azurerm_resource_group.network.name
  location            = module.azure_region.location_cli
  subnet_id           = module.synapse_network.vnet_subnets[local.compute_subnet_name]

  private_dns_zone_group {
    name                 = "sap-blob-dns-zone-group"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.tooling_storage["blob"].id]
  }

  private_service_connection {
    name                           = "sap-blob-connection"
    private_connection_resource_id = module.storage_account_sap_landing[0].storage_id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  tags = local.tags
}

# --- Secret Management (THEODW-3386) ---

# Store the primary access key in the ODW Key Vault (s62a pattern).
resource "azurerm_key_vault_secret" "sap_landing_storage_key" {
  count = var.deploy_sap_btp_landing ? 1 : 0

  name         = "SAP-Landing-Storage-Key"
  value        = module.storage_account_sap_landing[0].primary_access_key
  key_vault_id = module.synapse_data_lake.key_vault_id
  content_type = "text/plain"


  expiration_date = timeadd(timestamp(), "867834h")

  lifecycle {
    ignore_changes = [expiration_date]
  }
}

