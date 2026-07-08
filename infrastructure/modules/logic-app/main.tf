resource "azurerm_logic_app_workflow" "main" {
  name                = var.logic_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  parameters          = var.parameters
  workflow_parameters = var.workflow_parameters
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_logic_app_action_custom" "main" {
  for_each     = { for elem in var.custom_actions : elem.name => elem }
  name         = each.value.name
  logic_app_id = each.value.logic_app_id
  body         = each.value.body
}

resource "azurerm_logic_app_trigger_http_request" "main" {
  for_each     = { for elem in var.http_triggers : elem.name => elem }
  name         = each.value.name
  method       = each.value.method
  logic_app_id = each.value.logic_app_id
  schema       = each.value.schema
}
