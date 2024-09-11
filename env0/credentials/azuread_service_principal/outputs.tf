output "subscription_id" {
  value       = data.azurerm_subscription.current.subscription_id
  description = "Azure Subscription id"
}

output "tenant_id" {
  value    = data.azurerm_subscription.current.tenant_id
}

output "azure_credential" {
  value       = azuread_service_principal.env0.display_name
  description = "Azure SP"
}

# output "azure_cost_credentials" {
#   value = ""
#   description = "Azure Cost SP"
# }

output "expiration_date" { 
  value       = azuread_service_principal_password.env0.end_date
  description = "Date when SP Password expires"
}