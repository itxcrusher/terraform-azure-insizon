output "client_id" { value = azuread_application.app.client_id }
output "client_secret" {
  value     = azuread_application_password.pwd.value
  sensitive = true
}
output "object_id" { value = azuread_service_principal.spn.object_id }
output "secret_expiry" { value = azuread_application_password.pwd.end_date }
