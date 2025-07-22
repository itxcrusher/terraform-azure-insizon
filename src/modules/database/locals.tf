###############################################################################
# modules/database/locals.tf
# Central-point for every database-module local and helper resource
###############################################################################

#############################
# 1 ─ Static context
#############################
locals {
  # Naming & Environment
  db_name  = "${var.Database_object.AppName}-database"
  location = var.Database_object.Rg_Location
  env      = var.Database_object.AppEnvironment
  rg       = var.Database_object.Rg_Name

  # DB selection & sizing
  db_type  = lower(var.Database_object.Type) # "sql" | "postgresql"
  db_sku   = var.Database_object.Sku         # e.g. "GP_S_Gen5_2"
  db_size  = var.Database_object.SizeGB      # integer GB
  db_admin = var.Database_object.ServerAdminLogin

  # ── Helper: is this a serverless General-Purpose SKU? ─────────────
  is_serverless = can(regex("gp_s_", lower(local.db_sku)))

  # If serverless → pick provided MinCapacity or fallback to 0.5
  min_capacity_final = local.is_serverless ? (
    var.Database_object.MinCapacity != null ? var.Database_object.MinCapacity : 0.5
  ) : null

  # Tagging
  tags = {
    environment = local.env
    managed_by  = "Terraform"
    component   = "database"
  }

  # SQL-specific meta (outputs stay stable even when Postgres chosen)
  sql_license_type = var.Database_object.LicenseType # "BasePrice" | "LicenseIncluded"
  sql_enclave_type = var.Database_object.EnclaveType # "Default"  | "VBS"
  sql_collation    = var.Database_object.Collation   # e.g. "SQL_Latin1_General_CP1_CI_AS"

  license_type = local.is_serverless ? null : var.Database_object.LicenseType
}

#############################
# 2 ─ Password generation / normalisation
#############################

# Generate only when caller did not supply one
resource "random_password" "auto" {
  count       = var.Database_object.Password == "" ? 1 : 0
  length      = 22 # >18 chars is plenty for Azure SQL
  special     = true
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
}

locals {
  # Raw candidate (user-supplied or generated)
  _raw_pwd = var.Database_object.Password != "" ? var.Database_object.Password : random_password.auto[0].result

  # Does it break any Azure SQL rule?
  #  • must not start with a symbol
  #  • must not contain the admin login
  # _needs_fix = can(regex("^\\W", local._raw_pwd)) || contains(lower(local._raw_pwd), lower(local.db_admin))
  _needs_fix = can(regex("^\\W", local._raw_pwd)) || can(regex(lower(local.db_admin), lower(local._raw_pwd)))

  # Final password that **always** satisfies Azure SQL
  db_password = local._needs_fix ? "Az1${local._raw_pwd}!@" : local._raw_pwd
}
