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
    for b in local.service_bus_config : "${b.Name}-${b.Env}" => b
  }

  static_file_jobs = {
    for f in local.static_files_config : "${f.StorageAccountName}-${f.FolderName}" => f
  }
}

locals {
  additional_principals_by_app_env = {
    for app_key in keys(local.apps_by_name) : app_key => flatten([
      for uname, user in local.users_config : [
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
    for uname, user in local.users_config :
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

###############################################################################
# 3.  Placeholder test helper (regex string only)
###############################################################################
locals {
  placeholder_regex = "^\\$\\{"
}

locals {
  invalid_pat = var.github_token == "" ? false : !can(regex("^[a-zA-Z0-9_]{40}$", var.github_token))
}

###############################################################################
# 4.  Apps  → inject effective GitHub PAT
###############################################################################
locals {
  apps_by_name = {
    for app in local.apps_config :
    "${app.Name}-${app.Env}" => merge(app, {
      github_token = (
        app.Github == null
        ? null
        : (
          # token straight from YAML and not a ${placeholder}
          try(app.Github.token, "") != "" &&
          !can(regex(local.placeholder_regex, try(app.Github.token, "")))
        )
        ? app.Github.token
        : (var.github_token != "" ? var.github_token : null)
      )
    })
  }
}

###############################################################################
# 5.  Function-Apps → inject effective GitHub PAT
###############################################################################
locals {
  function_apps_by_name = {
    for fa in local.function_apps_config :
    "${fa.Name}-${fa.Env}" => merge(fa, {
      github_token = (
        fa.Github == null
        ? null
        : (
          try(fa.Github.token, "") != "" &&
          !can(regex(local.placeholder_regex, try(fa.Github.token, "")))
        )
        ? fa.Github.token
        : (var.github_token != "" ? var.github_token : null)
      )
    })
  }
}

###############################################################################
# 6.  RBAC logic
###############################################################################
locals {
  role_assignments = flatten([
    for uname, user in local.users_config : [
      for role in user.roles : [
        for app_key in (length(user.limit) > 0 ? user.limit : ["__subscription__"]) : {
          username      = uname
          role_name     = lookup(var.roles_lookup, role, "Reader")
          scope         = app_key == "__subscription__" ? "/subscriptions/${var.subscription_id}" : try(module.webapps[app_key].resource_group_id, null)
        }
      ]
    ]
  ])
}

resource "azurerm_role_assignment" "dynamic_user_roles" {
  for_each = {
    for item in local.role_assignments :
    "${item.username}-${item.role_name}-${item.scope}" => item
    if item.scope != null
  }

  principal_id         = module.entra_id_users.user_object_ids[each.value.username]
  role_definition_name = each.value.role_name
  scope                = each.value.scope
  principal_type       = "User"

  depends_on = [module.webapps]
}

locals {
  missing_scopes = [
    for item in local.role_assignments :
    item.app_key
    if item.app_key != "__subscription__" && !contains(keys(module.webapps), item.app_key)
  ]
}

resource "null_resource" "validate_app_refs" {
  count = length(local.missing_scopes) > 0 ? 1 : 0

  provisioner "local-exec" {
    command = "echo '⚠️ Invalid app references in users.yaml: ${join(", ", local.missing_scopes)}' && exit 1"
  }
}
