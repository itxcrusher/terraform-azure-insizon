output "logic_app_id" {
  value       = var.create_logic_app ? azurerm_logic_app_workflow.logic[0].id : null
  description = "Logic App resource ID"
}

output "trigger_callback_url" {
  value       = var.create_logic_app ? data.azurerm_logic_app_trigger_callback_url.manual[0].value : null
  description = "Callback URL for the HTTP trigger"
  sensitive   = true
}
