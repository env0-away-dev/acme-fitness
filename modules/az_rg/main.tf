terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.93.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}

data "azuread_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name       = "${var.prefix}-sales-rg"
  location   = var.location
  managed_by = data.azuread_client_config.current.object_id
}

variable "prefix" {
  type    = string
  default = "env0"
}

variable "location" {
  type    = string
  default = "eastus"
}

output "name" {
  value = azurerm_resource_group.example.name
}

output "location" {
  value = azurerm_resource_group.example.location
}

output "azuread_client_config_object_id" {
  value       = data.azuread_client_config.current.object_id
  description = "azuread_client_config.object_id"
}
