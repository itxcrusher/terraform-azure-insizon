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

# ---------- GitHub Source Control (optional) ----------
# Only create if a repo URL AND a usable PAT exist
# ───────── GitHub → Function App (Actions) ─────────
resource "azurerm_app_service_source_control" "github_fa" {
  count = local.enable_github_sc ? 1 : 0

  app_id   = local.windows_fa_id != null ? local.windows_fa_id : local.linux_fa_id
  repo_url = local.repo_url_safe
  branch   = local.branch_safe

  use_manual_integration = true
}

# ---------- Logic App (optional) ----------
resource "azurerm_logic_app_workflow" "fa_logic" {
  count               = local.enable_logic ? 1 : 0
  name                = substr("${local.app_name}-logic", 0, 60)
  location            = azurerm_resource_group.fa_rg.location
  resource_group_name = azurerm_resource_group.fa_rg.name

  # definition attribute is not supported in this provider version. Logic App will be created without a workflow definition.

  tags = local.tags
}
