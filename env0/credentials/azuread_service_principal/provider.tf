terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.1"
    }
    random = {
      source  = "hashicorp/random"
    }
    env0 = {
      source = "env0/env0"
    }
  }
}

provider "azuread" {
}

provider "azurerm" {
  # subscription_id = var.subscription_id
  features {}
}