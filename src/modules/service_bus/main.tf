################################################################################
# main.tf ── resources
################################################################################

# Shared RG per environment
resource "azurerm_resource_group" "sb_rg" {
  name     = local.rg_name
  location = var.location
  tags     = local.tags
}

# Namespaces per bus
resource "azurerm_servicebus_namespace" "ns" {
  for_each            = local.bus_map
  name                = "${each.value.Name}-${each.value.Env}-ns"
  location            = var.location
  resource_group_name = azurerm_resource_group.sb_rg.name

  sku      = each.value.Sku
  capacity = each.value.Sku == "Premium" ? 1 : null

  tags = {
    Environment = each.value.Env
    Application = each.value.Name
    Module      = "service_bus"
    ManagedBy   = "Terraform"
  }
}

# Connection string read
data "azurerm_servicebus_namespace_authorization_rule" "rootmanage" {
  for_each     = azurerm_servicebus_namespace.ns
  name         = "RootManageSharedAccessKey"
  namespace_id = each.value.id
}

# Queues
resource "azurerm_servicebus_queue" "queue" {
  for_each = local.queues_map

  name               = each.value.queue.name
  namespace_id       = azurerm_servicebus_namespace.ns[each.value.ns_name].id
  max_delivery_count = each.value.queue.MaxDeliveryCount
  default_message_ttl = each.value.queue.MessageTTL
}

# Topics
resource "azurerm_servicebus_topic" "topic" {
  for_each = local.topics_map

  name                   = each.value.topic.name
  namespace_id           = azurerm_servicebus_namespace.ns[each.value.ns_name].id
  max_size_in_megabytes  = each.value.topic.MaxTopicSize
  default_message_ttl    = each.value.topic.MessageTTL
}
