output "namespace_name" {
  value       = azurerm_servicebus_namespace.ns.name
  description = "Service-Bus namespace"
}

output "primary_connection_string" {
  value       = azurerm_servicebus_namespace_authorization_rule.rootmanage.primary_connection_string
  description = "RootManageSharedAccessKey connection string"
  sensitive   = true
}

output "topic_names" {
  value       = [for t in azurerm_servicebus_topic.topic : t.name]
  description = "Created topic names"
}

output "queue_names" {
  value       = [for q in azurerm_servicebus_queue.queue : q.name]
  description = "Created queue names"
}

output "resource_group" {
  value       = azurerm_resource_group.sb_rg.name
  description = "Resource group containing the namespace"
}
