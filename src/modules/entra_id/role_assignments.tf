# ─────────────────────────────────────────────────────────────
#  RBAC  ROLE  ASSIGNMENTS
# ─────────────────────────────────────────────────────────────
resource "azurerm_role_assignment" "user_roles" {
  for_each = {
    for idx, t in local.role_tuples :
    "${t.username}-${t.azure_role}-${idx}" => t
  }

  scope                = each.value.scope
  role_definition_name = each.value.azure_role
  principal_id         = azuread_user.this[each.value.username].object_id
  principal_type       = "User"
}
