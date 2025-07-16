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

output "client_id_secret_uri" {
  value       = azurerm_key_vault_secret.app_client_id.id
  description = "Key Vault secret URI for the client ID"
}

output "client_secret_uri" {
  value       = azurerm_key_vault_secret.app_client_secret.id
  description = "Key Vault secret URI for the client secret"
}

# ─── Redis outputs (null when not created) ─────────────────
output "redis_hostname" {
  description = "Redis DNS name (null if Redis not created)"
  value       = length(module.redis_cache) == 1 ? module.redis_cache[0].redis_hostname : null
}

output "redis_ssl_port" {
  description = "Redis TLS port"
  value       = length(module.redis_cache) == 1 ? module.redis_cache[0].redis_ssl_port : null
}

output "redis_key_secret_uri" {
  description = "Key Vault URI holding the primary Redis key (null when absent)"
  value       = length(azurerm_key_vault_secret.redis_primary_key) == 1 ? azurerm_key_vault_secret.redis_primary_key[0].id : null
}

output "storage_sas_tokens" {
  value = {
    for sa in var.webapp_object.StorageAccount :
    sa => data.azurerm_storage_account_sas.attached[sa].sas
  }
}

output "storage_names" {
  description = "List of storage account names attached to the web app"
  value       = keys(azurerm_storage_account.attached)
}

output "storage_sas_uris" {
  value = {
    for sa in var.webapp_object.StorageAccount :
    sa => data.azurerm_storage_account_sas.attached[sa].sas
  }
}

output "logic_app_id" {
  value       = local.enable_logic_app ? module.logic_app.logic_app_id : null
  description = "Logic App ID (if created)"
}

output "cdn_url" {
  value = local.use_cdn ? "https://${local.app_name}-endpoint.azureedge.net" : null
}
