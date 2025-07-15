output "database_name" {
  value = local.db_name
}

output "database_type" {
  value = local.db_type
}

output "connection_string" {
  description = "Fully-qualified endpoint for whichever DB we created"
  value       = length(azurerm_mssql_server.sql_server) == 1 ? azurerm_mssql_server.sql_server[0].fully_qualified_domain_name : azurerm_postgresql_flexible_server.pg_server[0].fqdn
}
