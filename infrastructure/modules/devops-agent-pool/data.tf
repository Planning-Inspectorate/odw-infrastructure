data "azurerm_image" "azure_agents" {
  count = var.deploy_agent_pool ? 1 : 0

  name                = "devops-agents-20260824131442"
  resource_group_name = azurerm_resource_group.devops_agents.name
}
