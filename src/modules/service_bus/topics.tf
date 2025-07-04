resource "azurerm_servicebus_topic" "topic" {
  for_each                       = local.topics_map
  name                           = each.value.name
  namespace_id                   = azurerm_servicebus_namespace.ns.id
  max_size_in_megabytes          = each.value.MaxTopicSize
  # default_message_time_to_live and tags are not supported in this provider version.
}
