# Web App Deployments
module "webapps" {
  for_each = local.apps_by_name
  source = "./modules/webapp"
  webapp_object = each.value
}

# Function Apps
module "function_apps" {
  for_each = local.function_apps_by_name
  source = "./modules/function_app"
  function_object = each.value
}

# Users / IAM
module "entra_id_users" {
  source          = "./modules/entra_id"
  users_object    = local.users_by_name
  subscription_id = var.subscription_id
  app_rg_map      = { for k, m in module.webapps : k => m.resource_group_id }
}

# Service Bus
module "service_bus" {
  for_each = local.service_buses_by_env
  source = "./modules/service_bus"
  bus_object = each.value
}

# Static File Deployments
module "static_files" {
  for_each = local.static_file_jobs
  source = "./modules/storage"
  file_object = each.value
}
