resource "azurerm_mssql_server" "sql_server" {
  count = local.db_type == "sql" ? 1 : 0

  name                         = "${var.Database_object.AppName}-sql-server"
  location                     = local.location
  resource_group_name          = local.rg
  version                      = "12.0"
  administrator_login          = local.db_admin
  administrator_login_password = local.db_password

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [administrator_login_password]
  }

  tags = local.tags
}

resource "azurerm_mssql_database" "sql_database" {
  count      = local.db_type == "sql" ? 1 : 0
  name       = local.db_name
  server_id  = azurerm_mssql_server.sql_server[0].id
  sku_name   = local.db_sku
  max_size_gb = local.db_size

  license_type = local.sql_license_type
  enclave_type = local.sql_enclave_type
  collation    = local.sql_collation

  tags = local.tags

  lifecycle {
    prevent_destroy = false
  }
}
