module "storage_account_openlineage" {
  count = var.open_lineage_enabled ? 1 : 0

  source = "./modules/storage-account"

  resource_group_name                     = azurerm_resource_group.function_app[0].name
  service_name                            = local.service_name
  environment                             = var.environment
  location                                = module.azure_region.location_cli
  tags                                    = local.tags
  network_rules_enabled                   = true
  network_rule_virtual_network_subnet_ids = concat([module.synapse_network.vnet_subnets[local.functionapp_subnet_name], module.synapse_network.vnet_subnets[local.compute_subnet_name]])
  container_name = [
    "openlineage-events",
    "openlineage-deadletter"
  ]
  tables = [
    "LineageJobs"
  ]
  shares = []
}
