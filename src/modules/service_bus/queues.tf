resource "azurerm_servicebus_queue" "queue" {
  for_each                       = local.queues_map
  name                           = each.value.name
  namespace_id                   = azurerm_servicebus_namespace.ns.id
  max_delivery_count             = each.value.MaxDeliveryCount
  # default_message_time_to_live is not supported in this provider version.
  # tags attribute is not supported in this provider version.
}
