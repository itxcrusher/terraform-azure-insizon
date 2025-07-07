resource "azurerm_windows_web_app" "main" {
  count               = local.os_type == "windows" ? 1 : 0
  name                = "${local.app_name}-web"
  location            = azurerm_service_plan.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  tags                = local.tags

  site_config {
    always_on = local.always_on_valid
    application_stack {
      dotnet_version = local.dotnet_ver
    }
  }

  app_settings = merge(
    local.enable_app_insights ? {
      "APPINSIGHTS_INSTRUMENTATIONKEY"        = local.app_insights_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = local.app_insights_connection
    } : {},
    {
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
    }
  )
}

resource "azurerm_linux_web_app" "main" {
  count               = local.os_type == "linux" ? 1 : 0
  name                = "${local.app_name}-web"
  location            = azurerm_service_plan.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  tags                = local.tags

  site_config {
    always_on = local.always_on_valid
    application_stack {
      node_version = local.os_type == "linux" && local.node_ver != "" ? local.node_ver : null
    }
  }

  app_settings = merge(
    local.enable_app_insights ? {
      "APPINSIGHTS_INSTRUMENTATIONKEY"        = local.app_insights_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = local.app_insights_connection
    } : {},
    {
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
    }
  )
}

###############################################################################
# Database (optional, only when webapp_object.Database is provided)
###############################################################################
module "database" {
  source = "../database"
  count  = var.webapp_object.Database == null ? 0 : 1

  Database_object = merge({
    AppName        = var.webapp_object.Name
    AppEnvironment = var.webapp_object.Env
    Rg_Location    = azurerm_resource_group.main.location
    Rg_Name        = azurerm_resource_group.main.name
  }, var.webapp_object.Database)
}

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

module "key_vault" {
  source = "../key_vault"

  keyvault_object = {
    AppName               = var.webapp_object.Name
    AppEnvironment        = var.webapp_object.Env
    Rg_Location           = azurerm_resource_group.main.location
    Rg_Name               = azurerm_resource_group.main.name
    TenantId              = var.tenant_id
    ObjectId              = var.webapp_object.ObjectId
    additional_principals = try(var.webapp_object.additional_principals, [])
  }
}

# ─── GitHub integration (manual, token is stored via azurerm_source_control_token) ───
resource "azurerm_app_service_source_control" "github" {
  count = local.enable_github_sc ? 1 : 0

  app_id   = local.windows_webapp_id != null ? local.windows_webapp_id : local.linux_webapp_id
  repo_url = local.git_repo_url
  branch   = local.git_branch

  use_manual_integration = true # keep site running during deploy
}

# App Insights
resource "azurerm_application_insights" "insights" {
  count               = local.enable_app_insights ? 1 : 0
  name                = "${local.app_name}-insights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  tags                = local.tags
}

# Logic App (stub)
resource "azurerm_logic_app_workflow" "logicapp" {
  count               = local.enable_logic_app ? 1 : 0
  name                = "${local.app_name}-logic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # definition attribute is not supported in this provider version. Logic App will be created without a workflow definition.

  tags = local.tags
}

# Custom Domain
resource "azurerm_app_service_custom_hostname_binding" "domain" {
  count               = var.webapp_object.CustomDomain != null ? 1 : 0
  hostname            = var.webapp_object.CustomDomain.URL
  app_service_name    = local.os_type == "windows" ? azurerm_windows_web_app.main[0].name : azurerm_linux_web_app.main[0].name
  resource_group_name = azurerm_resource_group.main.name
}
