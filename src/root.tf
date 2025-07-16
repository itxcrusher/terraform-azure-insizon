# Temporary Access SPN
module "temp_spns" {
  for_each = local.temp_spns_by_name
  source   = "./modules/temp_access_spn"

  name        = each.value.name
  ttl_hours   = each.value.ttl
  role_name   = each.value.role_name
  role_scopes = each.value.scopes
  tenant_id   = var.tenant_id
}

# App Registrations
module "app_registrations" {
  for_each = local.apps_by_name
  source   = "./modules/app_registration"

  display_name  = each.value.Name
  owner_ids     = [for uname in keys(local.service_bot_ids) : local.service_bot_ids[uname]]
  redirect_uris = try(each.value.CustomDomain.URL, null) != null ? ["https://${each.value.CustomDomain.URL}/auth/callback"] : []
}

# Users / IAM
module "entra_id_users" {
  source          = "./modules/entra_id"
  users_object    = local.users_by_name
  subscription_id = var.subscription_id
}

# Web App Deployments
module "webapps" {
  for_each = local.apps_by_name
  source   = "./modules/webapp"

  webapp_object = merge(
    each.value,
    {
      ObjectId              = try(local.service_bot_ids["service-bot"], null)
      additional_principals = try(local.additional_principals_by_app_env[each.key], [])
    }
  )

  tenant_id     = var.tenant_id
  client_id     = module.app_registrations[each.key].client_id
  client_secret = module.app_registrations[each.key].client_secret
}

# Function Apps
module "function_apps" {
  for_each        = local.function_apps_by_name
  source          = "./modules/function_app"
  function_object = each.value
  tenant_id       = var.tenant_id

  additional_principals = try(local.additional_principals_by_app_env[each.key], [])
}

# Service Bus
module "service_bus" {
  for_each    = local.service_buses_by_env
  source      = "./modules/service_bus"
  bus_objects = each.value.buses
  location    = each.value.location
}

# Static File Deployments
module "static_files" {
  for_each = local.static_file_jobs
  source   = "./modules/storage"

  enable_static_website = each.value.enable_static_website

  file_object = merge(
    {
      for k, v in each.value : k => v
      if k != "CustomDomain" && k != "EnableStaticWebsite" && k != "StaticWebsiteIndex" && k != "Error404Document"
    },
    {
      create_cdn    = each.value.create_cdn,
      custom_domain = try(each.value.CustomDomain, null)
    }
  )
}

###############################################################################
# 
###############################################################################
resource "azurerm_role_assignment" "app_scope_roles" {
  for_each = local.role_assignments_map

  principal_id         = module.entra_id_users.user_object_ids[each.value.username]
  role_definition_name = each.value.role_name
  scope                = each.value.scope

  depends_on = [
    module.webapps,
    module.function_apps,
    module.service_bus
  ]
}

resource "null_resource" "validate_app_refs" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "powershell.exe -Command \"if ('${join(",", local.missing_scopes)}' -ne '') { Write-Host 'Invalid app references in users.yaml:'; '${join("\\n", local.missing_scopes)}'; exit 1 } else { Write-Host 'All user app references are valid.' }\""
  }

#   provisioner "local-exec" {
#     command = <<EOT
# if [ "${join(",", local.missing_scopes)}" != "" ]; then
#   echo "Invalid app references in users.yaml:"
#   echo "${join("\\n", local.missing_scopes)}"
#   exit 1
# else
#   echo "All user app references are valid."
# fi
# EOT
#   }
}

resource "azurerm_key_vault_secret" "sb_queue_connections" {
  for_each = {
    for obj in flatten([
      for env, bus in local.service_buses_by_env : [
        for k, v in module.service_bus[env].connection_strings_per_queue :
        {
          key     = "sb-${env}-${k}"
          value   = v
          app_key = try(module.service_bus[env].queues_map[k].app_key, null)
          kv_id   = try(local.key_vault_ids_by_app[module.service_bus[env].queues_map[k].app_key], null)
        }
        if try(local.key_vault_ids_by_app[module.service_bus[env].queues_map[k].app_key], null) != null
      ]
    ]) :
    obj.key => obj
  }

  name         = each.value.key
  value        = each.value.value
  key_vault_id = each.value.kv_id

  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "sb_topic_connections" {
  for_each = {
    for obj in flatten([
      for env, bus in local.service_buses_by_env : [
        for k, v in module.service_bus[env].connection_strings_per_topic :
        {
          key     = "sb-${env}-${k}"
          value   = v
          app_key = try(module.service_bus[env].topics_map[k].app_key, null)
          kv_id   = try(local.key_vault_ids_by_app[module.service_bus[env].topics_map[k].app_key], null)
        }
        if try(local.key_vault_ids_by_app[module.service_bus[env].topics_map[k].app_key], null) != null
      ]
    ]) :
    obj.key => obj
  }

  name         = each.value.key
  value        = each.value.value
  key_vault_id = each.value.kv_id

  lifecycle {
    ignore_changes = [value]
  }
}
