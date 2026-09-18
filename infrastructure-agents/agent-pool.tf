module "agent_pool" {
  source = "./module"

  environment         = var.environment
  resource_group_name = "pins-rg-devops-odw-${var.environment}-uks"
  location            = "UK South"
  service_name        = local.service_name

  devops_agent_image_prefix = var.devops_agent_image_prefix
  devops_agent_instances    = var.devops_agent_instances
  devops_agent_vm_sku       = var.devops_agent_vm_sku
  subnet_id                 = data.azurerm_subnet.compute.id

  tags = local.tags
}

module "agent_pool_failover" {
  count  = var.environment != "build" ? 1 : 0
  source = "./module"

  environment         = var.environment
  resource_group_name = "pins-rg-devops-odw-${var.environment}-ukw"
  location            = "UK West"
  service_name        = local.service_name

  devops_agent_image_prefix = var.devops_agent_image_prefix
  devops_agent_instances    = var.devops_agent_instances
  devops_agent_vm_sku       = var.devops_agent_vm_sku
  subnet_id                 = data.azurerm_subnet.compute_failover.id

  tags = local.tags
}