resource "azurerm_logic_app_workflow" "logic" {
  count               = var.create_logic_app ? 1 : 0
  name                = "${var.name_prefix}-logic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Optional but keeps ARM happy
  workflow_parameters = jsonencode({ "$connections" = {} })

  # The full Logic App definition (triggers + actions) comes from root
  definition = jsonencode(var.definition)
}

data "azurerm_logic_app_trigger_callback_url" "manual" {
  count        = var.create_logic_app ? 1 : 0
  logic_app_id = azurerm_logic_app_workflow.logic[0].id
  trigger_name = "manual" # matches the trigger name inside JSON
}
