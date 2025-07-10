output "logic_app_id" {
  value       = var.create_logic_app ? azurerm_logic_app_workflow.logic[0].id : null
  description = "Logic App resource ID"
}

output "trigger_callback_url" {
  value       = var.create_logic_app ? azurerm_logic_app_trigger_http_request.http_trigger[0].callback_url : null
  description = "Callback URL for the HTTP trigger"
  sensitive   = true
}
