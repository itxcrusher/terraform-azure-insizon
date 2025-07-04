output "webapps" {
  value = {
    for k, m in module.webapps : k => m.app_url
  }
  description = "Deployed web app URLs"
}

output "function_apps" {
  value = {
    for k, m in module.function_apps : k => m.function_url
  }
  description = "Function App endpoints"
}

output "created_users" {
  value = {
    for k, m in module.entra_id_users : k => m.user_principal_name
  }
  description = "User principal names created in Entra ID"
}

output "static_files_summary" {
  value = {
    for k, m in module.static_files : k => m.upload_summary
  }
  description = "Summary of uploaded static files"
}
