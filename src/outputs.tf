###############################################################################
# 1️⃣  Web Apps
###############################################################################

output "webapp_urls" {
  description = "Default FQDNs for every Web App"
  value       = { for k, m in module.webapps : k => m.app_url }
}

output "webapp_custom_domains" {
  description = "Bound custom domains (null when none)"
  value       = { for k, m in module.webapps : k => m.custom_domain }
}

output "webapp_resource_groups" {
  description = "RG IDs that hold each Web App (useful for RBAC scoping)"
  value       = { for k, m in module.webapps : k => m.resource_group_id }
}

###############################################################################
# 2️⃣  Databases (per-app)
###############################################################################

output "databases" {
  description = "Engine + DB name per deployed app (null when app has no DB)"
  value = {
    for k, m in module.webapps :
    k => (
      m.has_database
      ? { type = m.database_type, name = m.database_name }
      : null
    )
  }
}

###############################################################################
# 3️⃣  Function Apps
###############################################################################

output "function_app_urls" {
  description = "Default hostnames for Function Apps"
  value       = { for k, m in module.function_apps : k => m.function_url }
}

output "function_app_insights" {
  description = "App Insights resource names (null when not created)"
  value       = { for k, m in module.function_apps : k => m.ai_name }
}

###############################################################################
# 4️⃣  Key Vaults
###############################################################################

output "key_vault_uris" {
  description = "Vault URIs per app"
  value       = { for k, m in module.webapps : k => m.key_vault_uri }
}

output "key_vault_secrets" {
  description = "Secret keys loaded into each vault"
  value       = { for k, m in module.webapps : k => m.key_vault_secrets }
}

###############################################################################
# 5️⃣  Service Bus
###############################################################################

output "service_bus_namespaces" {
  description = "Service-Bus namespaces per environment"
  value       = { for k, m in module.service_bus : k => m.namespace_name }
}

output "service_bus_topics" {
  description = "Topics created per namespace"
  value       = { for k, m in module.service_bus : k => m.topic_names }
}

output "service_bus_queues" {
  description = "Queues created per namespace"
  value       = { for k, m in module.service_bus : k => m.queue_names }
}

###############################################################################
# 6️⃣  Static-file Storage / CDN
###############################################################################

output "storage_accounts" {
  description = "Storage account → container map"
  value = {
    for k, m in module.static_files :
    k => {
      storage_account = m.storage_account_name
      container       = m.container_name
      cdn_hostname    = m.cdn_hostname
    }
  }
}

output "static_file_uploads" {
  description = "Files uploaded per static-file job"
  value       = { for k, m in module.static_files : k => m.upload_summary }
}

output "static_website_endpoints" {
  description = "Static website URL and CDN endpoint for each static-files job"
  value = {
    for job_key, job_mod in module.static_files :
    job_key => {
      static_website_url = job_mod.static_website_url
      cdn_url            = job_mod.cdn_url
    }
  }
}

###############################################################################
# 7️⃣  Entra ID Users / SPs
###############################################################################

output "entra_created_users" {
  description = "UPNs for newly-created Entra ID users"
  value       = module.entra_id_users.user_principal_names
}

output "entra_initial_passwords" {
  description = "Initial passwords—rotate ASAP"
  value       = module.entra_id_users.initial_passwords
  sensitive   = true
}

###############################################################################
# 8️⃣  Debug helpers
###############################################################################

output "apply_timestamp" {
  description = "When this state was last applied"
  value       = timestamp()
}
