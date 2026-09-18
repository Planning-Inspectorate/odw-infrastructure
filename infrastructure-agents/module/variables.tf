variable "devops_agent_image_prefix" {
  description = "The name prefix used to identify the devops agent image"
  type        = string
}

variable "devops_agent_instances" {
  description = "The base number of devops agents in the VM Scale Set"
  type        = number
}

variable "devops_agent_username" {
  default     = "agent_user"
  description = "The username of the devops agent local account"
  type        = string
}

variable "devops_agent_vm_sku" {
  description = "The size of the devops agent VMs to be deployed"
  type        = string
}

variable "environment" {
  description = "The name of the environment in which resources will be deployed"
  type        = string
}

variable "location" {
  description = "The Azure region into which resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group into which resources will be deployed"
  type        = string
}

variable "service_name" {
  description = "The short-format name of the overarching service being deployed"
  type        = string
}

variable "tags" {
  default     = {}
  description = "A collection of tags to assign to taggable resources"
  type        = map(string)
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}
