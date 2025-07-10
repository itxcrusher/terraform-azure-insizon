# ─────────────────────────────────────────────────────────────
#  SQL DATABASE RESOURCES
# ─────────────────────────────────────────────────────────────
resource "azurerm_mssql_server" "sql_server" {
  count = local.db_type == "sql" ? 1 : 0

  name                         = "${var.Database_object.AppName}-sql-server"
  location                     = local.location
  resource_group_name          = local.rg
  version                      = "12.0"
  administrator_login          = local.db_admin
  administrator_login_password = local.db_password

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = var.Database_object.ObjectId
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [administrator_login_password]
  }

  tags = local.tags
}

resource "azurerm_mssql_database" "sql_database" {
  count     = local.db_type == "sql" ? 1 : 0
  name      = local.db_name
  server_id = azurerm_mssql_server.sql_server[0].id

  # ── core spec ───────────────────────────────────────────
  sku_name    = local.db_sku            # GP_S_Gen5_2
  max_size_gb = var.Database_object.SizeGB
  collation   = local.sql_collation
  enclave_type = local.sql_enclave_type
  license_type = local.license_type     # null for serverless

  # ── serverless tweaks ──────────────────────────────────
  min_capacity               = local.min_capacity_final      # 0.5 for serverless
  auto_pause_delay_in_minutes = local.is_serverless ? 60 : null

  lifecycle {
    prevent_destroy = false
  }

  tags = local.tags
}

# ─────────────────────────────────────────────────────────────
#  POSTGRESQL DATABASE RESOURCES
# ─────────────────────────────────────────────────────────────
resource "azurerm_postgresql_flexible_server" "pg_server" {
  count = local.db_type == "postgresql" ? 1 : 0

  name                   = "${var.Database_object.AppName}-pg-server"
  resource_group_name    = local.rg
  location               = local.location
  sku_name               = local.db_sku
  version                = "13"
  administrator_login    = local.db_admin
  administrator_password = local.db_password
  storage_mb             = max(local.db_size * 1024, 32768)

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true # or false if you want strict AAD
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_postgresql_flexible_server_database" "pg_database" {
  count     = local.db_type == "postgresql" ? 1 : 0
  name      = local.db_name
  server_id = azurerm_postgresql_flexible_server.pg_server[0].id

  charset   = "UTF8"
  collation = "en_US.utf8"

  # tags attribute is not supported in this provider version.
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "aad_admin" {
  count               = local.db_type == "postgresql" ? 1 : 0
  server_name         = azurerm_postgresql_flexible_server.pg_server[0].name
  resource_group_name = local.rg

  object_id       = var.Database_object.ObjectId
  tenant_id       = var.Database_object.TenantId
  principal_type  = "User"
  principal_name  = "AzureAD Admin"
}
