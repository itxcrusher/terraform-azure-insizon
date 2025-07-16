# ###############################################################################
# # outputs.tf  ── consolidated success report for the entire Azure stack
# # -----------------------------------------------------------------------------
# # • All values funnel up from child modules.
# # • Sensitive data is flagged so `terraform output` hides it by default.
# # • Use `terraform output -json | jq` for machine‑readable inspection.
# ###############################################################################

# ###############################################################################
# # 1️⃣  Web Apps
# ###############################################################################

# output "webapp_urls" {
#   description = "Default FQDNs for every Web App"
#   value       = { for k, m in module.webapps : k => m.app_url }
# }

# output "webapp_custom_domains" {
#   description = "Bound custom domains (null when none)"
#   value       = { for k, m in module.webapps : k => m.custom_domain }
# }

# output "webapp_resource_groups" {
#   description = "Resource-group IDs that hold each Web App (useful for RBAC)"
#   value       = { for k, m in module.webapps : k => m.resource_group_id }
# }

# output "webapp_keyvaults" {
#   description = "Key Vault URI associated with each Web App"
#   value       = { for k, m in module.webapps : k => m.key_vault_uri }
# }

# output "webapp_databases" {
#   description = "Attached DB info per app (or null if none)"
#   value = {
#     for k, m in module.webapps :
#     k => (
#       m.has_database ? {
#         type = m.database_type
#         name = m.database_name
#       } : null
#     )
#   }
# }

# output "webapp_redis" {
#   description = "Redis config per Web App (null when Redis not created)"
#   value = {
#     for k, m in module.webapps : k => {
#       hostname = m.redis_hostname
#       ssl_port = m.redis_ssl_port
#     }
#   }
# }

# ###############################################################################
# # 2️⃣  Function Apps
# ###############################################################################

# output "function_app_urls" {
#   description = "Default hostnames for Function Apps"
#   value       = { for k, m in module.function_apps : k => m.function_url }
# }

# output "function_app_insights" {
#   description = "App Insights names (null when not created)"
#   value       = { for k, m in module.function_apps : k => m.ai_name }
# }

# output "function_app_keyvaults" {
#   description = "Key Vault linked to each Function App"
#   value       = { for k, m in module.function_apps : k => m.key_vault }
# }

# ###############################################################################
# # 3️⃣  Static Website Storage / CDN
# ###############################################################################

# output "static_storage" {
#   description = "Storage + CDN details for static-asset jobs"
#   value = {
#     for job_key, mod in module.static_files :
#     job_key => {
#       storage_account = mod.storage_account_name
#       container       = mod.container_name
#       cdn_url         = mod.cdn_url
#       static_url      = mod.static_website_url
#       files_uploaded  = mod.upload_summary
#     }
#   }
# }

# ###############################################################################
# # 4️⃣  Service Bus
# ###############################################################################

# output "service_bus_summary" {
#   description = "Namespaces, topics and queues per environment"
#   value = {
#     for env_key, mod in module.service_bus :
#     env_key => {
#       namespaces = mod.namespace_name
#       topics     = mod.topic_names
#       queues     = mod.queue_names
#     }
#   }
# }

# ###############################################################################
# # 5️⃣  Entra ID  (users + temporary SPNs)
# ###############################################################################

# output "entra_users" {
#   description = "Created Entra ID users → UPNs, object IDs, initial passwords"
#   value = {
#     usernames  = module.entra_id_users.user_principal_names
#     object_ids = module.entra_id_users.user_object_ids
#     passwords  = module.entra_id_users.initial_passwords
#   }
#   sensitive = true
# }

# output "temp_access_spn" {
#   description = "Short-lived service-principal for contractors"
#   value = {
#     client_id     = module.temp_access_spn.client_id
#     client_secret = module.temp_access_spn.client_secret
#     object_id     = module.temp_access_spn.object_id
#     secret_expiry = module.temp_access_spn.secret_expiry
#   }
#   sensitive = true
# }

# ###############################################################################
# # 6️⃣  App Registrations
# ###############################################################################

# output "app_registrations" {
#   description = "Core application-registration credentials"
#   value = {
#     client_id     = module.app_registration.client_id
#     client_secret = module.app_registration.client_secret
#     object_id     = module.app_registration.application_id
#   }
#   sensitive = true
# }

# ###############################################################################
# # 7️⃣  Key Vaults (global view)
# ###############################################################################

# output "keyvault_uris" {
#   description = "Vault URIs from Web Apps (Function-app vaults above)"
#   value       = { for k, m in module.webapps : k => m.key_vault_uri }
# }

# output "keyvault_secret_names" {
#   description = "Secret names loaded into each Web App vault"
#   value       = { for k, m in module.webapps : k => m.key_vault_secrets }
# }

# ###############################################################################
# # 8️⃣  Debug helpers
# ###############################################################################

# output "apply_timestamp" {
#   description = "RFC 3339 timestamp of the last successful terraform apply"
#   value       = timestamp()
# }
