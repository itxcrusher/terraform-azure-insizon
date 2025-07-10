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

output "custom_cdn_hostname" {
  description = "Custom CDN hostname (if set)"
  value       = var.file_object.custom_domain != null ? var.file_object.custom_domain : null
}

output "static_website_url" {
  value       = azurerm_storage_account.sa.primary_web_endpoint
  description = "Direct access to the static website (for testing or fallback)"
}

output "cdn_url" {
  description = "Public CDN URL"
  value       = try("https://${azurerm_cdn_endpoint_custom_domain.cdn_domain[0].host_name}", try(azurerm_cdn_endpoint.endpoint[0].host_name, null))
}
