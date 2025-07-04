locals {
  db_name = "${var.Database_object.AppName}-database"
  location = var.Database_object.Rg_Location
  env = var.Database_object.AppEnvironment
  rg  = var.Database_object.Rg_Name

  db_type = lower(var.Database_object.Type)

  db_sku = var.Database_object.Sku
  db_size = var.Database_object.SizeGB
  db_admin = var.Database_object.ServerAdminLogin
  db_password = var.Database_object.Password

  tags = {
    environment = local.env
    managed_by  = "Terraform"
    component   = "database"
  }

  sql_license_type = "LicenseIncluded"
  sql_enclave_type = "Default"
  sql_collation    = "SQL_Latin1_General_CP1_CI_AS"
}

###############################################################################
# Password handling
###############################################################################
resource "random_password" "auto" {
  count  = var.Database_object.Password == "" ? 1 : 0
  length = 20
  special = true
}

locals {
  db_password = var.Database_object.Password != "" ? var.Database_object.Password : random_password.auto[0].result

  sql_license_type = var.Database_object.LicenseType
  sql_enclave_type = var.Database_object.EnclaveType
  sql_collation    = var.Database_object.Collation
}

resource "local_file" "db_creds" {
  count    = var.Database_object.Password == "" ? 1 : 0   # only when auto generated
  filename = "${path.module}/../../../private/database_passwords/${var.Database_object.AppName}-${var.Database_object.AppEnvironment}-password.csv"
  content  = "username, password\n${var.Database_object.ServerAdminLogin},${local.db_password}"
  file_permission = "0600"
}
