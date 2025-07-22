###############################################################################
# Root Outputs – Full Project Output Summary
# ------------------------------------------
# Aligned with submodule exports only
###############################################################################

###############################################################################
# 1️⃣ Web Apps
###############################################################################

output "webapp_urls" {
  description = "Default FQDNs for each Web App"
  value       = { for k, m in module.webapps : k => m.app_url }
}

output "webapp_custom_domains" {
  description = "Custom domains (if any) for each Web App"
  value       = { for k, m in module.webapps : k => m.custom_domain }
}

output "webapp_resource_groups" {
  description = "Resource Group IDs for each Web App"
  value       = { for k, m in module.webapps : k => m.resource_group_id }
}

output "webapp_databases" {
  description = "Database engine + name per app (null if no DB)"
  value = {
    for k, m in module.webapps :
    k => (
      m.has_database ? {
        type = m.database_type,
        name = m.database_name
      } : null
    )
  }
}

output "webapp_keyvault_uris" {
  description = "Key Vault URIs created for each Web App"
  value       = { for k, m in module.webapps : k => m.key_vault_uri }
}

output "webapp_keyvault_secrets" {
  description = "List of secrets created in each app's vault"
  value       = { for k, m in module.webapps : k => m.key_vault_secrets }
}

output "webapp_redis" {
  description = "Redis details per Web App (null if not created)"
  value = {
    for k, m in module.webapps : k => {
      hostname = m.redis_hostname,
      ssl_port = m.redis_ssl_port
    }
  }
}

###############################################################################
# 2️⃣ Function Apps
###############################################################################

output "function_app_urls" {
  description = "Function App hostnames"
  value       = { for k, m in module.function_apps : k => m.function_url }
}

output "function_app_insights" {
  description = "Application Insights name per Function App"
  value       = { for k, m in module.function_apps : k => m.ai_name }
}

output "function_app_resource_groups" {
  description = "Resource groups per Function App"
  value       = { for k, m in module.function_apps : k => m.resource_group }
}

output "function_app_keyvaults" {
  description = "Key Vault IDs for Function Apps"
  value       = { for k, m in module.function_apps : k => m.key_vault }
}

###############################################################################
# 3️⃣ Static Website Storage / CDN
###############################################################################

output "static_storage" {
  description = "Static storage + CDN per static file job"
  value = {
    for job_key, mod in module.static_files :
    job_key => {
      storage_account = mod.storage_account_name,
      container       = mod.container_name,
      cdn_url         = mod.cdn_url,
      static_url      = mod.static_website_url,
      files_uploaded  = mod.upload_summary
    }
  }
}

###############################################################################
# 4️⃣ Azure Service Bus
###############################################################################

output "service_bus_summary" {
  description = "Service Bus topics, queues and namespaces"
  value = {
    for env_key, mod in module.service_bus :
    env_key => {
      namespaces = mod.namespace_name,
      topics     = mod.topic_names,
      queues     = mod.queue_names
    }
  }
}

###############################################################################
# 5️⃣ Microsoft Entra ID (Users)
###############################################################################

output "entra_users" {
  description = "Entra ID users created, with UPNs, object IDs, and passwords"
  value = {
    usernames  = module.entra_id_users.user_principal_names,
    object_ids = module.entra_id_users.user_object_ids,
    passwords  = module.entra_id_users.initial_passwords
  }
  sensitive = true
}

###############################################################################
# 6️⃣ Debug Metadata
###############################################################################

output "apply_timestamp" {
  description = "Timestamp of last successful apply"
  value       = timestamp()
}
