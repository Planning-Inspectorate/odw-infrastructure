resource "azurerm_resource_group" "data_management" {
  name     = "pins-rg-datamgmt-${local.resource_suffix}"
  location = module.azure_region.location_cli

  tags = local.tags
}

resource "azurerm_resource_group" "data_management_failover" {
  count = var.failover_deployment ? 1 : 0

  name     = "pins-rg-datamgmt-${local.resource_suffix_failover}"
  location = module.azure_region.paired_location.location_cli

  tags = local.tags
}

module "synapse_management" {
  source = "./modules/synapse-management"

  environment         = var.environment
  resource_group_name = azurerm_resource_group.data_management.name
  location            = module.azure_region.location_cli
  service_name        = local.service_name

  data_lake_account_id                   = module.synapse_data_lake.data_lake_account_id
  link_purview                           = var.link_purview_account
  devops_agent_subnet_name               = module.synapse_network.devops_agent_subnet_name
  firewall_allowed_ip_addresses          = local.firewall_allowed_ip_addresses
  key_vault_private_endpoint_dns_zone_id = azurerm_private_dns_zone.key_vault.id
  key_vault_role_assignments             = var.key_vault_role_assignments
  network_resource_group_name            = azurerm_resource_group.network.name
  synapse_private_endpoint_subnet_name   = module.synapse_network.synapse_private_endpoint_subnet_name
  vnet_subnet_ids                        = module.synapse_network.vnet_subnets
  vnet_subnet_ids_failover               = module.synapse_network_failover.vnet_subnets
  purview_msi_id                         = var.purview_msi_id

  tags = local.tags
}


# grant access to the data
resource "azurerm_synapse_role_assignment" "purview_synapse" {
  count                = var.link_purview_account ? 1 : 0
  synapse_workspace_id = module.synapse_workspace_private.synapse_workspace_id
  role_name            = "Synapse Contributor"
  principal_id         = var.purview_msi_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "purview_synapse" {
  count                = var.link_purview_account ? 1 : 0
  scope                = module.synapse_workspace_private.synapse_workspace_id
  role_definition_name = "Contributor"
  principal_id         = var.purview_msi_id
}

resource "azurerm_role_assignment" "purview_data" {
  count                = var.link_purview_account ? 1 : 0
  scope                = module.synapse_data_lake.data_lake_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.purview_msi_id
}

module "synapse_management_failover" {
  count = var.failover_deployment ? 1 : 0

  source = "./modules/synapse-management"

  environment         = var.environment
  resource_group_name = azurerm_resource_group.data_management_failover[0].name
  location            = module.azure_region.paired_location.location_cli
  service_name        = local.service_name

  data_lake_account_id                   = module.synapse_data_lake_failover.data_lake_account_id
  link_purview                           = false # Not supported in the UK West region
  devops_agent_subnet_name               = module.synapse_network_failover.devops_agent_subnet_name
  firewall_allowed_ip_addresses          = local.firewall_allowed_ip_addresses
  key_vault_private_endpoint_dns_zone_id = azurerm_private_dns_zone.key_vault.id
  key_vault_role_assignments             = var.key_vault_role_assignments
  network_resource_group_name            = azurerm_resource_group.network_failover.name
  synapse_private_endpoint_subnet_name   = module.synapse_network_failover.synapse_private_endpoint_subnet_name
  vnet_subnet_ids                        = module.synapse_network_failover.vnet_subnets
  vnet_subnet_ids_failover               = module.synapse_network.vnet_subnets
  purview_msi_id                         = var.purview_msi_id

  tags = local.tags
}

module "bastion_host" {
  count = var.bastion_host_enabled ? 1 : 0

  source = "./modules/bastion-host"

  environment         = var.environment
  resource_group_name = azurerm_resource_group.data_management.name
  location            = module.azure_region.location_cli
  service_name        = local.service_name

  bastion_vm_image             = var.bastion_vm_image
  bastion_vm_username          = var.bastion_vm_username
  bastion_vm_size              = var.bastion_vm_size
  key_vault_id                 = module.synapse_management.key_vault_id
  network_resource_group_name  = azurerm_resource_group.network.name
  synapse_compute_subnet_name  = local.compute_subnet_name
  synapse_vnet_security_groups = module.synapse_network.vnet_security_groups
  synapse_vnet_subnet_names    = module.synapse_network.vnet_subnets
  synapse_vnet_subnet_prefixes = module.synapse_network.vnet_subnet_prefixes

  tags = local.tags
}

module "bastion_host_failover" {
  count = var.bastion_host_enabled && var.failover_deployment ? 1 : 0

  source = "./modules/bastion-host"

  environment         = var.environment
  resource_group_name = azurerm_resource_group.data_management_failover[0].name
  location            = module.azure_region.paired_location.location_cli
  service_name        = local.service_name

  bastion_vm_image             = var.bastion_vm_image
  bastion_vm_username          = var.bastion_vm_username
  bastion_vm_size              = var.bastion_vm_size
  key_vault_id                 = module.synapse_management_failover[0].key_vault_id
  network_resource_group_name  = azurerm_resource_group.network_failover.name
  synapse_compute_subnet_name  = local.compute_subnet_name
  synapse_vnet_security_groups = module.synapse_network_failover.vnet_security_groups
  synapse_vnet_subnet_names    = module.synapse_network_failover.vnet_subnets
  synapse_vnet_subnet_prefixes = module.synapse_network_failover.vnet_subnet_prefixes

  tags = local.tags
}
