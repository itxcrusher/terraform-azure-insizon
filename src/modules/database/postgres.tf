resource "azurerm_postgresql_flexible_server" "pg_server" {
  count = local.db_type == "postgresql" ? 1 : 0

  name                = "${var.Database_object.AppName}-pg-server"
  resource_group_name = local.rg
  location            = local.location
  sku_name            = local.db_sku
  version             = "13"
  administrator_login          = local.db_admin
  administrator_password       = local.db_password
  storage_mb          = max(local.db_size * 1024, 32768)

  tags = local.tags
}

resource "azurerm_postgresql_flexible_database" "pg_database" {
  count     = local.db_type == "postgresql" ? 1 : 0
  name      = local.db_name
  server_id = azurerm_postgresql_flexible_server.pg_server[0].id

  charset   = "UTF8"
  collation = "en_US.utf8"

  tags = local.tags
}
