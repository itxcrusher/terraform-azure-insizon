# Gives apps an easy RootManageSharedAccessKey connection string
resource "azurerm_servicebus_namespace_authorization_rule" "rootmanage" {
  name         = "RootManageSharedAccessKey"
  namespace_id = azurerm_servicebus_namespace.ns.id

  listen = true
  send   = true
  manage = true
}
