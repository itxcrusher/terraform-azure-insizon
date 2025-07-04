# SKU map for every plan variant
locals {
  plan_sku = {
    consumption      = "Y1"
    flexconsumption  = "Y2"
    appservice_win   = "B1"
    appservice_linux = "B1"
  }
}

resource "azurerm_service_plan" "fa_plan" {
  name                = substr("${local.app_name}-fa-plan", 0, 60)
  resource_group_name = azurerm_resource_group.fa_rg.name
  location            = azurerm_resource_group.fa_rg.location

  kind    = "FunctionApp"
  os_type = local.os_type_title

  sku_name = (
    local.plan_type_lower == "appservice" ? (local.os_type_lower == "windows" ? local.plan_sku.appservice_win : local.plan_sku.appservice_linux) : local.plan_sku[local.plan_type_lower]
  )

  tags = local.tags
}
