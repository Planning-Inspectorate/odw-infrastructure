# Legacy manually-created logic app that has been migrated to Terraform
module "specialist_case_validation_check" {
  source              = "./modules/logic-app"
  logic_app_name      = "odw-specialist-case-validation-check-${var.environment}"
  resource_group_name = azurerm_resource_group.data.name
  location            = var.location

  custom_actions = [
    {
      name         = "Get_blob_content_using_path_V2"
      logic_app_id = var.specialist_case_validation_check_logic_app_migration_ids[var.environment]
      body = jsonencode({
        inputs = {
          host = {
            connection = {
              name = "@parameters('$connections')['azureblob-1']['connectionId']"
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
      body = jsonencode({
        inputs = {
          body = {
            Attachments = [{
              ContentBytes = "@{body('Get_blob_content_using_path_V2')?['$content']}"
              Name         = "@triggerBody()?['fileName']"
            }]
            Body       = "@{triggerBody()?['bodyHtml']}"
            From       = "svc_sharepoint_pins_o365@pinso365.onmicrosoft.com"
            Importance = "Normal"
            Subject    = "@triggerBody()?['subject']"
            To         = var.specialist_case_validation_check_recipients
          }
          host = {
            connection = {
              name = "@parameters('$connections')['office365']['connectionId']"
            }
          }
          method = "post"
          path   = "/v2/Mail"
        }
        runAfter = {
          Get_blob_content_using_path_V2 = ["Succeeded"]
        }
        type = "ApiConnection"
      })
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
  to = module.specialist_case_validation_check.azurerm_logic_app_workflow.main
  id = var.specialist_case_validation_check_logic_app_migration_ids[var.environment]

}

import {
  to = module.specialist_case_validation_check.azurerm_logic_app_action_custom.main["Get_blob_content_using_path_V2"]
  id = "${var.specialist_case_validation_check_logic_app_migration_ids[var.environment]}/actions/Get_blob_content_using_path_V2"
}

import {
  to = module.specialist_case_validation_check.azurerm_logic_app_action_custom.main["Send_an_email_(V2)"]
  id = "${var.specialist_case_validation_check_logic_app_migration_ids[var.environment]}/actions/Send_an_email_(V2)"
}

import {
  to = module.specialist_case_validation_check.azurerm_logic_app_trigger_http_request.main["When_an_HTTP_request_is_received"]
  id = "${var.specialist_case_validation_check_logic_app_migration_ids[var.environment]}/triggers/When_an_HTTP_request_is_received"
}
