output "client_id" {
  description = "Client ID for app registration"
  value       = azuread_application.this.client_id
}

output "client_secret" {
  description = "Client secret (password)"
  value       = azuread_application_password.this.value
  sensitive   = true
}

output "application_id" {
  description = "App object ID"
  value       = azuread_application.this.id
}
