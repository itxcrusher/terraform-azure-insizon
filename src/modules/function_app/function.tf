# ---------- Application Insights (optional) ----------
resource "azurerm_application_insights" "ai" {
  count               = local.enable_ai ? 1 : 0
  name                = substr("${local.app_name}-ai", 0, 60)
  location            = azurerm_resource_group.fa_rg.location
  resource_group_name = azurerm_resource_group.fa_rg.name
  application_type    = "web"
  tags                = local.tags
}

# ---------- Base app settings ----------
locals {
  app_settings_base = {
    FUNCTIONS_WORKER_RUNTIME       = local.runtime_lang
    WEBSITE_RUN_FROM_PACKAGE       = "1"
  }

  app_settings = merge(
    local.app_settings_base,
    local.enable_ai ? {
      APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.ai[0].instrumentation_key
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.ai[0].connection_string
    } : {}
  )
}

# ---------- Windows Function App ----------
resource "azurerm_windows_function_app" "fa_win" {
  count               = local.os_type_lower == "windows" ? 1 : 0
  name                = substr("${local.app_name}-fa", 0, 60)
  resource_group_name = azurerm_resource_group.fa_rg.name
  location            = azurerm_resource_group.fa_rg.location

  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  service_plan_id            = azurerm_service_plan.fa_plan.id

  functions_extension_version = "~4"
  site_config {
    ftps_state = "Disabled"
    application_stack {
      node_version   = local.runtime_lang == "node"   ? "~${local.runtime_ver}" : null
      dotnet_version = local.runtime_lang == "dotnet" ? "v${local.runtime_ver}" : null
      powershell_core_version = local.runtime_lang == "powershell" ? local.runtime_ver : null
    }
  }

  app_settings = local.app_settings
  tags         = local.tags

  identity {
    type = "SystemAssigned"
  }
}

# ---------- Linux Function App ----------
resource "azurerm_linux_function_app" "fa_linux" {
  count               = local.os_type_lower == "linux" ? 1 : 0
  name                = substr("${local.app_name}-fa", 0, 60)
  resource_group_name = azurerm_resource_group.fa_rg.name
  location            = azurerm_resource_group.fa_rg.location

  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  service_plan_id            = azurerm_service_plan.fa_plan.id

  functions_extension_version = "~4"
  site_config {
    ftps_state = "Disabled"
    application_stack {
      node_version   = local.runtime_lang == "node"   ? "~${local.runtime_ver}" : null
      dotnet_version = local.runtime_lang == "dotnet" ? "v${local.runtime_ver}" : null
    }
  }

  app_settings = local.app_settings
  tags         = local.tags

  identity {
    type = "SystemAssigned"
  }
}
