output "key_vault_name" {
  value       = azurerm_key_vault.this.name
  description = "Name of the created Key Vault"
}

output "secrets_uploaded" {
  value       = [for k in azurerm_key_vault_secret.secrets : k.name]
  description = "List of secret keys uploaded to the vault"
}

output "vault_uri" {
  value       = azurerm_key_vault.this.vault_uri
  description = "Vault URI (https://<name>.vault.azure.net/)"
}

output "vault_id" {
  value       = azurerm_key_vault.this.id
  description = "Key Vault resource ID"
}

output "diagnostic_enabled" {
  value       = var.log_analytics_workspace_id != ""
  description = "True if diagnostics are enabled for Key Vault"
}
