# ─────────────────────────────────────────────────────────────
#  USER CREATION  (azuread_user)
# ─────────────────────────────────────────────────────────────
data "azuread_domains" "primary" {
  only_initial = true
}

resource "random_password" "pwd" {
  for_each = var.users_object
  length   = var.password_length
  special  = true
}

resource "azuread_user" "this" {
  for_each            = var.users_object

  user_principal_name = "${each.value.username}@${data.azuread_domains.primary.domains[0].domain_name}"
  display_name        = each.value.fullName
  mail_nickname       = each.value.username

  password             = random_password.pwd[each.key].result
  force_password_change = true
}
