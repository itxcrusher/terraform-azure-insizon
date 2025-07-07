################################################################################
# main.tf ── resources
################################################################################

# ── Resource Group ────────────────────────────────────────────────────────────
resource "azurerm_resource_group" "sb_rg" {
  name     = local.rg_name
  location = var.location
  tags     = local.tags
}

# ── Namespace ────────────────────────────────────────────────────────────────
resource "azurerm_servicebus_namespace" "ns" {
  name                = local.ns_name
  location            = azurerm_resource_group.sb_rg.location
  resource_group_name = azurerm_resource_group.sb_rg.name

  sku      = local.sku
  capacity = local.sku == "Premium" ? 1 : null # capacity only valid on Premium

  tags = local.tags
}

# Azure auto-creates “RootManageSharedAccessKey”.  We *read* it instead of
# trying to recreate (avoids import errors).
data "azurerm_servicebus_namespace_authorization_rule" "rootmanage" {
  name         = "RootManageSharedAccessKey"
  namespace_id = azurerm_servicebus_namespace.ns.id
}

# ── Queues ────────────────────────────────────────────────────────────────────
resource "azurerm_servicebus_queue" "queue" {
  for_each = local.queues_map

  name               = each.value.name
  namespace_id       = azurerm_servicebus_namespace.ns.id
  max_delivery_count = each.value.MaxDeliveryCount

  # default_message_time_to_live not yet exposed in provider v3.x
  # tags not yet supported in provider v3.x
}

# ── Topics ────────────────────────────────────────────────────────────────────
resource "azurerm_servicebus_topic" "topic" {
  for_each = local.topics_map

  name                  = each.value.name
  namespace_id          = azurerm_servicebus_namespace.ns.id
  max_size_in_megabytes = each.value.MaxTopicSize

  # default_message_time_to_live & tags not yet supported in provider v3.x
}
