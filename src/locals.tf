locals {
  # Decode YAML files
  apps_config          = yamldecode(file("${path.module}/config/apps.yaml")).apps
  users_config         = yamldecode(file("${path.module}/config/users.yaml")).users
  function_apps_config = yamldecode(file("${path.module}/config/function-apps.yaml")).function_apps
  service_bus_config   = yamldecode(file("${path.module}/config/service-bus.yaml")).buses
  static_files_config  = yamldecode(file("${path.module}/config/static-files.yaml")).files

  # Add GitHub token into each app/function config
  apps_by_name = {
    for app in local.apps_config :
    "${app.Name}-${app.Env}" => merge(app, {
      github_token = app.Github != null ? (
        contains(keys(app.Github), "token") ? app.Github.token : var.github_token
      ) : null
    })
  }

  function_apps_by_name = {
    for fa in local.function_apps_config :
    "${fa.Name}-${fa.Env}" => merge(fa, {
      github_token = fa.Github != null ? (
        contains(keys(fa.Github), "token") ? fa.Github.token : var.github_token
      ) : null
    })
  }

  users_by_name = {
    for user in local.users_config :
    user.username => user
  }

  service_buses_by_env = {
    for bus in local.service_bus_config :
    "${bus.Name}-${bus.Env}" => bus
  }

  static_file_jobs = {
    for f in local.static_files_config :
    "${f.StorageAccountName}-${f.FolderName}" => f
  }
}
