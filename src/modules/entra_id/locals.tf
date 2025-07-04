# ─────────────────────────────────────────────────────────────
#  LOCALS –  flatten roles → scopes
# ─────────────────────────────────────────────────────────────
locals {
  # Build list of {username, azure_role, scope}
  role_matrix = flatten([
    for uname, udef in var.users_object : [
      for r in udef.roles : {
        username   = uname
        azure_role = lookup(var.roles_lookup, r, null)
        scopes     = length(udef.limit) > 0 ? [for app in udef.limit : lookup(var.app_rg_map, app, null)] : ["/subscriptions/${var.subscription_id}"]
      }
    ]
  ])

  # explode scopes so each tuple is unique
  role_tuples = flatten([
    for rm in local.role_matrix : [
      for sc in rm.scopes : {
        username   = rm.username
        azure_role = rm.azure_role
        scope      = sc
      } if rm.azure_role != null && sc != null
    ]
  ])
}
