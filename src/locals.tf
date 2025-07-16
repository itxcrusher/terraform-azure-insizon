###############################################################################
# 1.  Decode all YAML files
###############################################################################
locals {
  apps_config          = yamldecode(file("${path.module}/config/apps.yaml")).apps
  users_config         = yamldecode(file("${path.module}/config/users.yaml")).users
  function_apps_config = yamldecode(file("${path.module}/config/function-apps.yaml")).function_apps
  service_bus_config   = yamldecode(file("${path.module}/config/service-bus.yaml")).buses
  static_files_config  = yamldecode(file("${path.module}/config/static-files.yaml")).files
}

###############################################################################
# 2.  Simple look-up maps
###############################################################################
locals {
  users_by_name = {
    for u in local.users_config : u.username => u
  }

  service_buses_by_env = {
    for env in distinct([for b in local.service_bus_config : b.Env]) :
    env => {
      env      = env
      location = try([for b in local.service_bus_config : b.Location if b.Env == env][0], "centralus")
      buses    = [for b in local.service_bus_config : b if b.Env == env]
    }
  }

  static_file_jobs = {
    for f in local.static_files_config : "${f.StorageAccountName}-${f.FolderName}" => merge(f, {
      enable_static_website = try(f.EnableStaticWebsite, false),
      static_website_index  = try(f.StaticWebsiteIndex, null),
      error_404_document    = try(f.Error404Document, null)
    })
  }
}

locals {
  additional_principals_by_app_env = {
    for app_key in keys(local.apps_by_name) : app_key => flatten([
      for uname, user in local.users_by_name : [
        for role in user.roles : {
          principal_id   = module.entra_id_users.user_object_ids[uname]
          role           = lookup(var.roles_lookup, role, "Reader")
          principal_type = "User"
        }
        if length(user.limit) == 0 || contains(user.limit, app_key)
      ]
    ])
  }
}

locals {
  service_bot_by_app = {
    for uname, user in local.users_by_name :
    uname => user
    if contains(user.roles, "serviceAccount")
  }
}

locals {
  service_bot_ids = {
    for uname in keys(local.service_bot_by_app) :
    uname => module.entra_id_users.user_object_ids[uname]
  }
}

locals {
  key_vault_ids_by_app = {
    for app_key, app in local.apps_by_name :
    app_key => module.webapps[app_key].key_vault_uri
  }
}

###############################################################################
# 3.  Placeholder test helper (regex string only)
###############################################################################
locals {
  placeholder_regex = "^\\$\\{"
}

###############################################################################
# 4.  Apps
###############################################################################
locals {
  apps_by_name = {
    for app in local.apps_config :
    "${app.Name}-${app.Env}" => app
  }
}

###############################################################################
# 5.  Function-Apps
###############################################################################
locals {
  function_apps_by_name = {
    for fa in local.function_apps_config :
    "${fa.Name}-${fa.Env}" => fa
  }
}

###############################################################################
# 6.  RBAC logic
###############################################################################
# Phase 1: Assignments for subscription-scoped users
locals {
  role_assignments_sub_scope = flatten([
    for uname, user in local.users_by_name : [
      for role in user.roles : [
        {
          username       = uname
          role_name      = lookup(var.roles_lookup, role, "Reader")
          scope          = "/subscriptions/${var.subscription_id}"
          principal_type = role == "serviceAccount" ? "ServicePrincipal" : "User"
        }
      ]
      if length(user.limit) == 0 || contains(user.limit, "__subscription__")
    ]
  ])
}

# Phase 2: Assignments for users limited to apps (webapps, functions, buses)
locals {
  role_assignments_resource_scope = flatten([
    for uname, user in local.users_by_name : [
      for role in user.roles : [
        for app_key in user.limit : {
          username       = uname
          role_name      = lookup(var.roles_lookup, role, "Reader")
          scope          = (
            contains(keys(module.webapps), app_key) ? module.webapps[app_key].resource_group_id :
            contains(keys(module.function_apps), app_key) ? module.function_apps[app_key].resource_group_id :
            contains(keys(module.service_bus), app_key) ? module.service_bus[app_key].resource_group_id :
            null
          )
          principal_type = role == "serviceAccount" ? "ServicePrincipal" : "User"
          app_key        = app_key
        }
      ]
    ]
  ])
}

locals {
  valid_app_keys = concat(
    keys(module.webapps),
    keys(module.function_apps),
    keys(module.service_bus)
  )

  role_assignments_map = {
    for item in local.role_assignments_resource_scope :
    "${item.username}-${item.role_name}-${item.app_key}" => item
    if contains(local.valid_app_keys, item.app_key)
  }
}

locals {
  missing_scopes = [
    for item in local.role_assignments_resource_scope :
    item.app_key
    if item.scope == null
  ]
}

###############################################################################
# TEMP-SPNs CONFIG
###############################################################################
locals {
  temp_spns_config = yamldecode(file("${path.module}/config/temp-access.yaml")).temp_spns

  temp_spns_by_name = {
    for s in local.temp_spns_config :
    s.Name => {
      name      = s.Name
      role_name = try(s.RoleName, "Reader")
      scopes = [
        for raw in s.Scopes :
        replace(raw, "$${SUBSCRIPTION_ID}", var.subscription_id)
      ]
      ttl = tonumber(try(s.TTLHours, 168))
    }
  }
}
