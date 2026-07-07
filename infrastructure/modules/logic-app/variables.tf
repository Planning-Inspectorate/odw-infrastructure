variable "logic_app_name" {
  description = "The name of the logic app"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group the logic app should belong to"
  type        = string
}

variable "location" {
  description = "The short-format Azure region into which resources will be deployed"
  type        = string
}

variable "custom_actions" {
  type = list(object({
    name         = string
    logic_app_id = string
    body         = string
  }))
  default = []
}

variable "http_triggers" {
  type = list(object({
    name         = string
    logic_app_id = string
    method       = string
    schema       = string
  }))
  default = []
}
