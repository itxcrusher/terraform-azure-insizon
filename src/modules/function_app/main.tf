resource "azurerm_resource_group" "fa_rg" {
  name     = substr("${local.app_name}-fa-rg", 0, 90)
  location = var.location
  tags     = local.tags
}

resource "azurerm_service_plan" "fa_plan" {
  name                = substr("${local.app_name}-fa-plan", 0, 60)
  resource_group_name = azurerm_resource_group.fa_rg.name
  location            = azurerm_resource_group.fa_rg.location

  os_type = local.os_type_title

  sku_name = (
    local.plan_type_lower == "appservice" ? (local.os_type_lower == "windows" ? local.plan_sku.appservice_win : local.plan_sku.appservice_linux) : local.plan_sku[local.plan_type_lower]
  )

  tags = local.tags
}

# Uniqueness helper
resource "random_id" "storage_suffix" {
  byte_length = 3
}

resource "azurerm_storage_account" "sa" {
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.fa_rg.name
  location                 = azurerm_resource_group.fa_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}

# ---------- Logic App (optional) ----------
module "logic_app" {
  source              = "../logic_app"
  create_logic_app    = local.enable_logic
  name_prefix         = local.app_name
  location            = azurerm_resource_group.fa_rg.location
  resource_group_name = azurerm_resource_group.fa_rg.name
  definition          = jsondecode(file("${path.module}/../../config/logic-definition.json")).definition
  tags                = local.tags
}
