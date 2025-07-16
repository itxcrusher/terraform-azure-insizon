data "azuread_client_config" "current" {}

resource "azuread_application" "this" {
  display_name = var.display_name
  owners       = concat(var.owner_ids, [data.azuread_client_config.current.object_id])

  web {
    redirect_uris = var.redirect_uris
  }

  dynamic "app_role" {
    for_each = var.app_roles
    content {
      allowed_member_types = app_role.value.allowed_member_types
      description          = app_role.value.description
      display_name         = app_role.value.display_name
      enabled              = app_role.value.is_enabled
      value                = app_role.value.value
      id                   = app_role.value.id
    }
  }
}

resource "time_sleep" "wait_for_graph" {
  depends_on      = [azuread_application.this]
  create_duration = "25s" # bump from 15 to 25 for reliability
}

resource "azuread_service_principal" "this" {
  client_id  = azuread_application.this.client_id
  depends_on = [time_sleep.wait_for_graph]
}

resource "azuread_application_password" "this" {
  application_id = azuread_application.this.id
  display_name   = "Default"

  depends_on = [time_sleep.wait_for_graph]
}
