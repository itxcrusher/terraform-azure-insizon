output "user_principal_names" {
  value       = { for k, u in azuread_user.this : k => u.user_principal_name }
  description = "UPNs for newly-created users."
}

output "initial_passwords" {
  sensitive   = true
  value       = { for k, p in random_password.pwd : k => p.result }
  description = "First-login passwords (rotate after delivery!)."
}

output "user_object_ids" {
  description = "Map of usernames to their object IDs"
  value       = { for k, u in azuread_user.this : k => u.object_id }
}
