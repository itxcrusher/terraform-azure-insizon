output "logic_app_id" {
  value       = var.create_logic_app ? azurerm_logic_app_workflow.logic[0].id : null
  description = "Logic App resource ID"
}
