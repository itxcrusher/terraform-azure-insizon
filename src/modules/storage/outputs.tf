output "storage_account_name" {
  value       = azurerm_storage_account.sa.name
  description = "Storage account created/used"
}

output "container_name" {
  value       = azurerm_storage_container.container.name
  description = "Blob container name"
}

output "cdn_hostname" {
  description = "CDN endpoint FQDN (null when create_cdn = false)"
  value       = try("${azurerm_cdn_endpoint.endpoint[0].name}.azureedge.net", null)
}

output "upload_summary" {
  value       = [for f in local.include_files : f]
  description = "List of files uploaded"
}
