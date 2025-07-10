resource "azuread_application" "this" {
  display_name = var.display_name
  owners       = var.owner_ids

  web {
    redirect_uris = var.redirect_uris
  }

  dynamic "app_role" {
    for_each = var.app_roles
    content {
      allowed_member_types = app_role.value.allowed_member_types
      description          = app_role.value.description
      display_name         = app_role.value.display_name
      enabled              = app_role.value.is_enabled # Use 'enabled' instead of 'is_enabled'
      value                = app_role.value.value
      id                   = app_role.value.id
    }
  }
}

resource "azuread_service_principal" "this" {
  client_id = azuread_application.this.client_id
}

resource "azuread_application_password" "this" {
  application_id = azuread_application.this.id
  display_name   = "Default"
  # end_date      = "<ISO timestamp>" # Optional: set if you want a specific expiration
}
