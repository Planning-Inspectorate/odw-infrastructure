terraform {
  backend "azurerm" {
    # per-environment key in the pipeline with "-backend-config" flag
    container_name       = "terraformstate-odw"
    resource_group_name  = "pins-rg-shared-terraform-uks"
    subscription_id      = "edb1ff78-90da-4901-a497-7e79f966f8e2"
    storage_account_name = "pinsstsharedtfstateuks"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "> 4"
    }
  }
  required_version = ">= 1.15.0, < 1.17.0"
}

provider "azurerm" {
  resource_provider_registrations = "none"

  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}
