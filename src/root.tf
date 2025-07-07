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

  tenant_id = var.tenant_id
}

# Function Apps
module "function_apps" {
  for_each        = local.function_apps_by_name
  source          = "./modules/function_app"
  function_object = each.value
}

# Service Bus
module "service_bus" {
  for_each   = local.service_buses_by_env
  source     = "./modules/service_bus"
  bus_object = each.value
}

# Static File Deployments
module "static_files" {
  for_each    = local.static_file_jobs
  source      = "./modules/storage"
  file_object = each.value
}

###############################################################################
# GitHub PAT – one per subscription
###############################################################################
resource "azurerm_source_control_token" "github" {
  count = var.github_token != "" ? 1 : 0

  type         = "GitHub"
  token        = var.github_token # PAT from dev.tfvars / CI secret
  token_secret = var.github_token # provider requires both fields
}
