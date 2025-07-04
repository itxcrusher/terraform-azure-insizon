resource "azurerm_resource_group" "main" {
  name     = "${local.app_name}-rg"
  location = local.location
  tags     = local.tags
}

resource "azurerm_service_plan" "main" {
  name                = "${local.app_name}-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = title(local.os_type)
  sku_name            = local.sku_name
  tags                = local.tags
}
