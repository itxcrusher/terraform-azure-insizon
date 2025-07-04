resource "azurerm_windows_web_app" "main" {
  count               = local.os_type == "windows" ? 1 : 0
  name                = "${local.app_name}-web"
  location            = azurerm_service_plan.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  tags                = local.tags

  site_config {
    always_on = local.always_on
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
    always_on = local.always_on
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
