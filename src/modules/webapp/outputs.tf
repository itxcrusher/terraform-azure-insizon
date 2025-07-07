output "app_url" {
  description = "Default hostname of the deployed web app"
  value       = local.windows_webapp_url != null ? local.windows_webapp_url : local.linux_webapp_url
}

output "custom_domain" {
  description = "Custom domain bound to the web app (if any)"
  value       = var.webapp_object.CustomDomain != null ? var.webapp_object.CustomDomain.URL : null
}

output "resource_group_id" {
  description = "ID of the web-app resource-group (used for RBAC scoping)."
  value       = azurerm_resource_group.main.id
}

###############################################################################
# Database passthrough (null when no Database section in YAML)
###############################################################################

output "database_type" {
  description = "Underlying DB engine (sql | postgresql) or null when omitted"
  value = (
    length(module.database) == 1
    ? module.database[0].database_type
    : null
  )
}

output "database_name" {
  description = "DB name or null when no DB"
  value = (
    length(module.database) == 1
    ? module.database[0].database_name
    : null
  )
}

output "has_database" {
  description = "True when this webapp includes a database"
  value       = length(module.database) == 1
}

###############################################################################
#  Key-Vault passthrough
###############################################################################
output "key_vault_uri" {
  description = "URI of the Key Vault for this app"
  value       = module.key_vault.vault_uri
}

output "key_vault_secrets" {
  description = "Secret names uploaded to the vault"
  value       = module.key_vault.secrets_uploaded
}
