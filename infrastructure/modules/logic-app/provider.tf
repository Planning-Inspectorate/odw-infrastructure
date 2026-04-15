terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "> 3.74.0, <5.0.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.9.0"
    }
  }
}
