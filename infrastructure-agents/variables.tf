variable "devops_agent_image_prefix" {
  default     = "devops-agents"
  description = "The name prefix used to identify the devops agent image"
  type        = string
}

variable "devops_agent_instances" {
  default     = 0
  description = "The base number of devops agents in the VM Scale Set"
  type        = number
}

variable "devops_agent_vm_sku" {
  default     = "Standard_F2s_v2"
  description = "The size of the devops agent VMs to be deployed"
  type        = string
}

variable "environment" {
  description = "The name of the environment in which resources will be deployed"
  type        = string
}
variable "tags" {
  default     = {}
  description = "A collection of tags to assign to taggable resources"
  type        = map(string)
}

variable "system_asset_owner" {
  description = "tagging - value extracted from ADO library secret"
  type        = string
  sensitive   = true
  default     = ""
}