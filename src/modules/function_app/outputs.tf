output "function_url" {
  value = local.os_type_lower == "windows" ? local.windows_fa_url : local.linux_fa_url
}

output "ai_name" {
  description = "Application Insights instance name (if created)"
  value       = local.enable_ai ? azurerm_application_insights.ai[0].name : null
}

output "resource_group" {
  value       = azurerm_resource_group.fa_rg.name
  description = "Resource group containing the Function App"
}

output "storage_account" {
  value       = azurerm_storage_account.sa.name
  description = "Backing storage account name"
}
