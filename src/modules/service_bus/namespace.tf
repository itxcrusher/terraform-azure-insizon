resource "azurerm_servicebus_namespace" "ns" {
  name                = local.ns_name
  location            = azurerm_resource_group.sb_rg.location
  resource_group_name = azurerm_resource_group.sb_rg.name

  sku = "Standard"   # Change to "Premium" via YAML later if needed

  # Capacity is ignored by Standard; include only for Premium
  dynamic "capacity" {
    for_each = sku == "Premium" ? [1] : []
    content  = capacity.value   # ==> sets capacity = 1 when Premium
  }

  tags = local.tags
}
