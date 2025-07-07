# Inherit root provider, but module-level declaration silences
# “provider not configured” warnings for `azuread_user`.
terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}

# ─────────────────────────────────────────────────────────────
#  STATIC  ROLE  TUPLES  (username • role • target app)
#  – keys are known at plan-time –
# ─────────────────────────────────────────────────────────────
locals {
  # produce one tuple per (user, role, target)
  role_tuples_raw = flatten([
    for uname, u in var.users_object : [
      for role in u.roles : [
        # if limit[] empty → attach at subscription
        for target_app in(length(u.limit) > 0 ? u.limit : ["__subscription__"]) : {
          username   = uname
          azure_role = lookup(var.roles_lookup, role, null)
          target_app = target_app # may be "__subscription__"
        }
      ]
    ]
  ])

  # build for_each-ready map with *static* keys
  role_tuple_map = {
    for rt in local.role_tuples_raw :
    "${rt.username}-${rt.azure_role}-${rt.target_app}" => rt
    if rt.azure_role != null
  }
}
