output "checkmark_managed_identity_client_id" {
  description = "The client ID of the Checkmark Managed Identity"
  value       = var.checkmark_managed_identity_enabled ? azurerm_user_assigned_identity.checkmark[0].client_id : null
}

output "checkmark_managed_identity_name" {
  description = "The name of the Checkmark Managed Identity"
  value       = var.checkmark_managed_identity_enabled ? azurerm_user_assigned_identity.checkmark[0].name : null
}

output "checkmark_managed_identity_principal_id" {
  description = "The object (principal) ID of the Checkmark Managed Identity in Microsoft Entra ID"
  value       = var.checkmark_managed_identity_enabled ? azurerm_user_assigned_identity.checkmark[0].principal_id : null
}

output "data_lake_account_id" {
  description = "The ID of the Data Lake Storage Account"
  value       = var.failover_deployment ? module.synapse_data_lake.data_lake_account_id : module.synapse_data_lake.data_lake_account_id
}

output "data_lake_account_id_failover" {
  description = "The ID of the Data Lake Storage Account used for backup and failover"
  value       = var.failover_deployment ? module.synapse_data_lake.data_lake_account_id : module.synapse_data_lake.data_lake_account_id
}

output "data_lake_account_name" {
  description = "The name of the Data Lake Storage Account"
  value       = var.failover_deployment ? module.synapse_data_lake.data_lake_account_name : module.synapse_data_lake.data_lake_account_name
}

output "data_lake_dfs_endpoint" {
  description = "The DFS endpoint URL of the Data Lake Storage Account"
  value       = var.failover_deployment ? module.synapse_data_lake.data_lake_dfs_endpoint : module.synapse_data_lake.data_lake_dfs_endpoint
}

output "data_lake_dfs_endpoint_failover" {
  description = "The DFS endpoint URL of the Data Lake Storage Account used for backup and failover"
  value       = var.failover_deployment ? module.synapse_data_lake.data_lake_dfs_endpoint : module.synapse_data_lake.data_lake_dfs_endpoint
}

output "data_resource_group_name" {
  description = "The name of the data application resource group"
  value       = var.failover_deployment ? azurerm_resource_group.data_failover.name : azurerm_resource_group.data.name
}

output "devops_agent_pool_resource_group_name" {
  description = "The name of the resource group containing the devops agent pool resources"
  value       = var.failover_deployment && var.devops_agent_failover_enabled ? module.devops_agent_pool_failover.resource_group_name : module.devops_agent_pool.resource_group_name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = var.failover_deployment ? module.synapse_data_lake.key_vault_uri : module.synapse_data_lake.key_vault_uri
}

output "service_bus_namespace_name" {
  description = "The name of the Service Bus Namespace"
  value       = var.failover_deployment ? module.synapse_ingestion_failover.service_bus_namespace_name : module.synapse_ingestion.service_bus_namespace_name
}

output "service_bus_primary_connection_string" {
  description = "The primary connection string of the Service Bus Namespace"
  value       = var.failover_deployment ? module.synapse_ingestion_failover.service_bus_primary_connection_string : module.synapse_ingestion.service_bus_primary_connection_string
  sensitive   = true
}

output "synapse_dev_endpoint" {
  description = "The development connectivity endpoint for the Synapse Workspace"
  value       = var.failover_deployment ? one(module.synapse_workspace_private_failover).synapse_endpoints["dev"] : module.synapse_workspace_private.synapse_endpoints["dev"]
}

output "synapse_dsql_endpoint" {
  description = "The dedicated SQL pool connectivity endpoint for the Synapse Workspace"
  value       = var.failover_deployment ? one(module.synapse_workspace_private_failover).synapse_endpoints["sql"] : module.synapse_workspace_private.synapse_endpoints["sql"]
}

output "synapse_ssql_endpoint" {
  description = "The serverless SQL pool connectivity endpoint for the Synapse Workspace"
  value       = var.failover_deployment ? one(module.synapse_workspace_private_failover).synapse_endpoints["sqlOnDemand"] : module.synapse_workspace_private.synapse_endpoints["sqlOnDemand"]
}

output "synapse_workspace_id" {
  description = "The ARM ID of the Synapse Workspace"
  value       = var.failover_deployment ? one(module.synapse_workspace_private_failover).synapse_workspace_id : module.synapse_workspace_private.synapse_workspace_id
}

output "synapse_workspace_name" {
  description = "The name of the Synapse Workspace"
  value       = var.failover_deployment ? one(module.synapse_workspace_private_failover).synapse_workspace_name : module.synapse_workspace_private.synapse_workspace_name
}

# --- SAP BTP Landing Zone (THEODW-3385) ---
# These outputs are the deliverables handed to the MHCLG/SAP team so they can
# create their side of the Private Link connection.
output "sap_pls_alias" {
  description = "The Private Link Service alias to be shared with the SAP BTP team. Null when deploy_sap_btp_landing is false."
  value       = var.deploy_sap_btp_landing ? one(azurerm_private_link_service.sap[*].alias) : null
}

output "sap_pls_id" {
  description = "The Private Link Service resource ID for the SAP BTP integration. Null when deploy_sap_btp_landing is false."
  value       = var.deploy_sap_btp_landing ? one(azurerm_private_link_service.sap[*].id) : null
}

output "sap_landing_storage_id" {
  description = "The resource ID of the SAP BTP landing storage account. Null when deploy_sap_btp_landing is false."
  value       = var.deploy_sap_btp_landing ? one(module.storage_account_sap_landing[*].storage_id) : null
}

# --- SAP BTP OAuth Authentication (THEODW-3387) ---
# Handover fields for the MHCLG/SAP BTP team. Client secret is intentionally
# NOT surfaced as an output - retrieve it from Key Vault (`sap-btp-client-secret`)
# so it never lands in the Terraform state file in plaintext outside of the
# `azuread_application_password` resource itself.
output "sap_btp_tenant_id" {
  description = "Microsoft Entra ID Tenant ID used for OAuth token requests. Null when deploy_sap_btp_landing is false."
  value       = var.deploy_sap_btp_landing ? data.azurerm_client_config.current.tenant_id : null
}

output "sap_btp_client_id" {
  description = "Application (Client) ID of the SAP BTP App Registration. Null when deploy_sap_btp_landing is false."
  value       = var.deploy_sap_btp_landing ? one(azuread_application.sap_btp[*].client_id) : null
}

output "sap_btp_token_endpoint" {
  description = "OAuth 2.0 v2 token endpoint MHCLG uses to exchange client credentials for an access token."
  value       = var.deploy_sap_btp_landing ? "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/oauth2/v2.0/token" : null
}

output "sap_btp_client_secret_kv_secret_name" {
  description = "Name of the Key Vault secret that holds the current SAP BTP client secret."
  value       = var.deploy_sap_btp_landing ? one(azurerm_key_vault_secret.sap_btp_client_secret[*].name) : null
}

