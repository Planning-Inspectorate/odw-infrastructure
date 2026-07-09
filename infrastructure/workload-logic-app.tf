# Legacy manually-created logic app that has been migrated to Terraform

resource "azurerm_api_connection" "azure_blob" {
  count               = var.az_api_blob_connection_names[var.environment] != null ? 1 : 0
  managed_api_id      = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Web/locations/uksouth/managedApis/azureblob"
  name                = var.az_api_blob_connection_names[var.environment]
  resource_group_name = azurerm_resource_group.data.name
}

import {
  for_each = var.az_api_blob_connection_names[var.environment] != null ? toset([1]) : toset([])
  to       = azurerm_api_connection.azure_blob[0]
  id       = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/pins-rg-data-odw-${var.environment}-uks/providers/Microsoft.Web/connections/${var.az_api_blob_connection_names[var.environment]}"
}

resource "azurerm_api_connection" "office_365" {
  count               = var.az_api_office365_connection_names[var.environment] != null ? 1 : 0
  managed_api_id      = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Web/locations/uksouth/managedApis/office365"
  name                = var.az_api_office365_connection_names[var.environment]
  resource_group_name = azurerm_resource_group.data.name
}

import {
  for_each = var.az_api_office365_connection_names[var.environment] != null ? toset([1]) : toset([])
  to       = azurerm_api_connection.office_365[0]
  id       = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/pins-rg-data-odw-${var.environment}-uks/providers/Microsoft.Web/connections/${var.az_api_office365_connection_names[var.environment]}"
}

module "specialist_case_validation_check" {
  count               = var.specialist_case_validation_check_logic_app_enabled ? 1 : 0
  source              = "./modules/logic-app"
  logic_app_name      = "odw-specialist-case-validation-check-${var.environment}"
  resource_group_name = azurerm_resource_group.data.name
  location            = module.azure_region.location_cli
  parameters = {
    "$connections" = jsonencode(
      {
        "azureblob" : {
          "connectionId" : azurerm_api_connection.azure_blob[0].id,
          "connectionName" : azurerm_api_connection.azure_blob[0].name,
          "connectionProperties" : {
            "authentication" : {
              "type" : "ManagedServiceIdentity"
            }
          },
          "id" : azurerm_api_connection.azure_blob[0].managed_api_id
        },
        "office365" : {
          "connectionId" : azurerm_api_connection.office_365[0].id,
          "connectionName" : azurerm_api_connection.office_365[0].name,
          "connectionProperties" : {},
          "id" : azurerm_api_connection.office_365[0].managed_api_id
        }
      }
    )
  }
  workflow_parameters = {
    "$connections" = jsonencode(
      { "defaultValue" : {}, "type" : "Object" }
    )
  }

  custom_actions = [
    {
      name         = "Get_blob_content_using_path_V2"
      logic_app_id = var.specialist_case_validation_check_logic_app_migration_ids[var.environment]
      body = jsonencode({
        inputs = {
          host = {
            connection = {
              name = "@parameters('$connections')['${var.az_api_blob_connection_names[var.environment]}']['connectionId']"
            }
          }
          method = "get"
          path   = "/v2/datasets/@{encodeURIComponent(encodeURIComponent(triggerBody()?['storageAccountName']))}/GetFileContentByPath"
          queries = {
            inferContentType             = false
            path                         = "@triggerBody()?['storagePath']"
            queryParametersSingleEncoded = true
          }
        }
        runAfter = {}
        type     = "ApiConnection"
      })
    },
    {
      name         = "Send_an_email_(V2)"
      logic_app_id = var.specialist_case_validation_check_logic_app_migration_ids[var.environment]
      body = jsonencode(
        {
          "runAfter" : {
            "Get_blob_content_using_path_V2" : [
              "Succeeded"
            ]
          },
          "type" : "ApiConnection",
          "inputs" : {
            "host" : {
              "connection" : {
                "name" : "@parameters('$connections')['${var.az_api_office365_connection_names[var.environment]}']['connectionId']"
              }
            },
            "method" : "post",
            "body" : {
              "To" : var.specialist_case_validation_check_recipients,
              "Subject" : "@triggerBody()?['subject']",
              "Body" : "<p class=\"editor-paragraph\">@{triggerBody()?['bodyHtml']}</p>",
              "From" : "svc_sharepoint_pins_o365@pinso365.onmicrosoft.com",
              "Attachments" : [
                {
                  "Name" : "@{triggerBody()?['fileName']}",
                  "ContentBytes" : "@{body('Get_blob_content_using_path_V2')?['$content']}"
                }
              ],
              "Importance" : "Normal"
            },
            "path" : "/v2/Mail"
          }
        }
      )
    }
  ]
  http_triggers = [
    {
      name         = "When_an_HTTP_request_is_received"
      logic_app_id = var.specialist_case_validation_check_logic_app_migration_ids[var.environment]
      method       = "POST"
      schema = jsonencode({
        properties = {
          bodyHtml = {
            type = "string"
          }
          fileName = {
            type = "string"
          }
          storageAccountName = {
            type = "string"
          }
          storagePath = {
            type = "string"
          }
          subject = {
            type = "string"
          }
          to = {
            type = "string"
          }
        }
        type = "object"
      })
    }
  ]
}

import {
  for_each = var.specialist_case_validation_check_logic_app_enabled ? toset([1]) : toset([])
  to       = module.specialist_case_validation_check[0].azurerm_logic_app_workflow.main
  id       = var.specialist_case_validation_check_logic_app_migration_ids[var.environment]

}

import {
  for_each = var.specialist_case_validation_check_logic_app_enabled ? toset(["Get_blob_content_using_path_V2", "Send_an_email_(V2)"]) : toset([])
  to       = module.specialist_case_validation_check[0].azurerm_logic_app_action_custom.main[each.value]
  id       = "${var.specialist_case_validation_check_logic_app_migration_ids[var.environment]}/actions/${each.value}"
}

import {
  for_each = var.specialist_case_validation_check_logic_app_enabled ? toset([1]) : toset([])
  to       = module.specialist_case_validation_check[0].azurerm_logic_app_trigger_http_request.main["When_an_HTTP_request_is_received"]
  id       = "${var.specialist_case_validation_check_logic_app_migration_ids[var.environment]}/triggers/When_an_HTTP_request_is_received"
}
