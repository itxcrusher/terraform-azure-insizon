output "app_url" {
  description = "Default hostname of the deployed web app"
  value       = local.windows_webapp_url != null ? local.windows_webapp_url : local.linux_webapp_url
}

output "custom_domain" {
  description = "Custom domain bound to the web app (if any)"
  value       = var.webapp_object.CustomDomain != null ? var.webapp_object.CustomDomain.URL : null
}
