output "storage_account_name" {
  value       = azurerm_storage_account.sa.name
  description = "Storage account created/used"
}

output "container_name" {
  value       = azurerm_storage_container.container.name
  description = "Blob container name"
}

output "cdn_hostname" {
  value       = length(azurerm_cdn_endpoint.endpoint) == 1 ? azurerm_cdn_endpoint.endpoint[0].host_name : null
  description = "CDN endpoint (if create_cdn = true)"
}

output "upload_summary" {
  value       = [for f in local.include_files : f]
  description = "List of files uploaded"
}
