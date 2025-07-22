data "azuread_client_config" "current" {}

resource "azuread_application" "app" {
  display_name = var.name
  owners       = [data.azuread_client_config.current.object_id]
  tags         = ["temp-access"]
}

resource "time_sleep" "wait_for_graph" {
  depends_on      = [azuread_application.app]
  create_duration = "25s"
}

resource "azuread_service_principal" "spn" {
  client_id  = azuread_application.app.client_id
  depends_on = [time_sleep.wait_for_graph]
}

resource "azuread_application_password" "pwd" {
  application_id = azuread_application.app.id
  display_name   = "terraform-generated"
  depends_on     = [time_sleep.wait_for_graph]
}

resource "azurerm_role_assignment" "rbac" {
  for_each             = toset(var.role_scopes)
  principal_id         = azuread_service_principal.spn.object_id
  role_definition_name = var.role_name
  scope                = each.value
}

resource "null_resource" "mkdir_temp_access" {
  provisioner "local-exec" {
    # command = "mkdir -p ${path.root}/private/entra_access_keys"
    command = "powershell.exe -Command \"New-Item -ItemType Directory -Force -Path '${path.root}/../private/entra_access_keys'\""
  }
}

resource "local_file" "creds" {
  filename = "${path.root}/../private/entra_access_keys/${var.name}.json"
  content = jsonencode({
    client_id     = azuread_application.app.client_id
    client_secret = azuread_application_password.pwd.value
    tenant_id     = var.tenant_id
    object_id     = azuread_service_principal.spn.id
    expiry        = azuread_application_password.pwd.end_date
  })

  file_permission = "0600"
  depends_on      = [null_resource.mkdir_temp_access]
}
