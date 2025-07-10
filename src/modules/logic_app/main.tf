resource "azurerm_logic_app_workflow" "logic" {
  count               = var.create_logic_app ? 1 : 0
  name                = "${var.name_prefix}-logic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# ──────────────────────────────────────────────
#  HTTP Trigger: Accepts incoming HTTP calls
# ──────────────────────────────────────────────
resource "azurerm_logic_app_trigger_http_request" "http_trigger" {
  count        = var.create_logic_app ? 1 : 0
  name         = "manual"
  logic_app_id = azurerm_logic_app_workflow.logic[0].id
  schema       = "{}"
}

# ──────────────────────────────────────────────
#  Response Action: Sends back success message
# ──────────────────────────────────────────────
resource "azurerm_logic_app_action_response" "response" {
  count        = var.create_logic_app ? 1 : 0
  name         = "respondOK"
  logic_app_id = azurerm_logic_app_workflow.logic[0].id
  status_code  = 200
  body = jsonencode({
    message = "Logic App executed successfully!"
  })

  depends_on = [azurerm_logic_app_trigger_http_request.http_trigger]
}
