################################################################################
# outputs.tf ── handy details for callers / CI
################################################################################

output "namespace_name" {
  description = "Service-Bus namespace name"
  value       = azurerm_servicebus_namespace.ns.name
}

output "primary_connection_string" {
  description = "RootManageSharedAccessKey connection string (keep secret!)"
  value       = data.azurerm_servicebus_namespace_authorization_rule.rootmanage.primary_connection_string
  sensitive   = true
}

output "topic_names" {
  description = "All topic names in the namespace"
  value       = [for t in azurerm_servicebus_topic.topic : t.name]
}

output "queue_names" {
  description = "All queue names in the namespace"
  value       = [for q in azurerm_servicebus_queue.queue : q.name]
}

output "resource_group" {
  description = "Name of the RG that holds the namespace"
  value       = azurerm_resource_group.sb_rg.name
}
