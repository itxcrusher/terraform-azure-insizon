################################################################################
# outputs.tf ── handy details for callers / CI
################################################################################

output "namespace_names" {
  description = "All Service-Bus namespace names"
  value       = [for ns in azurerm_servicebus_namespace.ns : ns.name]
}

output "namespace_connection_strings" {
  description = "RootManageSharedAccessKey connection strings per namespace"
  value = {
    for k, v in data.azurerm_servicebus_namespace_authorization_rule.rootmanage :
    k => v.primary_connection_string
  }
  sensitive = true
}


output "topic_names" {
  description = "All topic names across all namespaces"
  value       = [for t in azurerm_servicebus_topic.topic : t.name]
}

output "queue_names" {
  description = "All queue names across all namespaces"
  value       = [for q in azurerm_servicebus_queue.queue : q.name]
}

output "resource_group" {
  description = "Shared RG used for all Service Bus namespaces in this environment"
  value       = azurerm_resource_group.sb_rg.name
}

output "connection_strings_per_queue" {
  description = "Map of queue name keys to connection string"
  value = {
    for q in local.queues_map :
    q.key => data.azurerm_servicebus_namespace_authorization_rule.rootmanage[replace(q.ns_name, "-ns", "")].primary_connection_string
  }
  sensitive = true
}

output "connection_strings_per_topic" {
  description = "Map of topic name keys to connection string"
  value = {
    for t in local.topics_map :
    t.key => data.azurerm_servicebus_namespace_authorization_rule.rootmanage[replace(t.ns_name, "-ns", "")].primary_connection_string
  }
  sensitive = true
}

output "queues_map" {
  value = local.queues_map
}

output "topics_map" {
  value = local.topics_map
}

output "namespace_name" {
  value = [for ns in azurerm_servicebus_namespace.ns : ns.name]
}
