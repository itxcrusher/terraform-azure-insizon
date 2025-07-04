# GitHub integration
resource "azurerm_app_service_source_control" "github" {
  count = var.webapp_object.Github != null ? 1 : 0

  # personal_access_token is not supported in this provider version. Remove or replace with oauth_token if supported.

  app_id                 = local.windows_webapp_id != null ? local.windows_webapp_id : local.linux_webapp_id
  repo_url               = local.git_repo_url
  branch                 = local.git_branch
  use_manual_integration = true
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
