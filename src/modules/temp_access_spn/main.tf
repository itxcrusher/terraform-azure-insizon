########################
# 1)  App & SPN
########################
resource "azuread_application" "app" {
  display_name = var.name
  owners       = []
  tags         = ["temp-access"]
}

resource "azuread_service_principal" "spn" {
  client_id = azuread_application.app.client_id
}

########################
# 2)  Secret (password)
########################
resource "azuread_application_password" "pwd" {
  application_id = azuread_application.app.id
  display_name   = "terraform-generated"
  # end_date    = "<ISO timestamp>" # Optional: set if you want a specific expiration
}

########################
# 3)  RBAC per scope
########################
resource "azurerm_role_assignment" "rbac" {
  for_each             = toset(var.role_scopes)
  principal_id         = azuread_service_principal.spn.id
  role_definition_name = var.role_name
  scope                = each.value
}

########################
# 4)  Drop creds to disk
########################
resource "null_resource" "mkdir_temp_access" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.root}/private/entra_access_keys"
  }
}

resource "local_file" "creds" {
  filename = "${path.root}/private/entra_access_keys/${var.name}.json"
  content = jsonencode({
    client_id     = azuread_application.app.application_id
    client_secret = azuread_application_password.pwd.value
    tenant_id     = var.tenant_id
    object_id     = azuread_service_principal.spn.id
    expiry        = azuread_application_password.pwd.end_date
  })
  file_permission = "0600"

  depends_on = [null_resource.mkdir_temp_access]
}
