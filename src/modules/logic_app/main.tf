resource "azurerm_logic_app_workflow" "logic" {
  count               = var.create_logic_app ? 1 : 0
  name                = "${var.name_prefix}-logic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Optional but keeps ARM happy
  workflow_parameters = {
    "$connections" = "{}"
  }
}
