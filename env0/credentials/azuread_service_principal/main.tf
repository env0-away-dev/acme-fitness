locals {
  env-vars = jsondecode(file("env0.system-env-vars.json"))
  org_id   = local.env-vars.ENV0_ORGANIZATION_ID
}

module "random-pet" {
  source = "../../../modules/random_pet"
}

data "azuread_client_config" "current" {}

data "azurerm_subscription" "current" {}

resource "azuread_application" "env0" {
  display_name = "env0.${module.random-pet.name}"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "env0" {
  client_id                    = azuread_application.env0.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "time_rotating" "refresh" {
  rotation_days = 180
}

resource "azuread_service_principal_password" "env0" {
  display_name         = var.azure_sp_name
  service_principal_id = azuread_service_principal.env0.object_id
  rotate_when_changed  = { rotation = time_rotating.refresh.id }
}

resource "env0_azure_credentials" "credentials" {
  name            = var.azure_sp_name
  client_id       = azuread_application.env0.client_id
  client_secret   = azuread_service_principal_password.env0.value
  subscription_id = data.azurerm_subscription.current.id
  tenant_id       = data.azuread_client_config.current.tenant_id
}