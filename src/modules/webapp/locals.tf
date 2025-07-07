locals {
  app_name        = "${var.webapp_object.Name}-${var.webapp_object.Env}"
  location        = var.webapp_object.Location
  os_type         = lower(var.webapp_object.OsType)
  sku_name        = var.webapp_object.Sku
  dotnet_ver      = var.webapp_object.DotnetVersion
  node_ver        = var.webapp_object.NodeVersion
  always_on_valid = var.webapp_object.AlwaysOn && !contains(["F1", "D1", "Free_F1"], var.webapp_object.Sku)

  enable_app_insights = var.webapp_object.CreateAppInsight
  enable_logic_app    = var.webapp_object.CreateLogicApp

  git_repo_url = var.webapp_object.Github != null ? var.webapp_object.Github.repoUrl : null
  git_branch   = try(var.webapp_object.Github.branch, var.webapp_object.Env)

  tags = {
    Environment = var.webapp_object.Env
    Application = var.webapp_object.Name
    ManagedBy   = "Terraform"
  }

  app_insights_key        = try(azurerm_application_insights.insights[0].instrumentation_key, null)
  app_insights_connection = try(azurerm_application_insights.insights[0].connection_string, null)

  windows_webapp_id  = try(azurerm_windows_web_app.main[0].id, null)
  linux_webapp_id    = try(azurerm_linux_web_app.main[0].id, null)
  windows_webapp_url = try(azurerm_windows_web_app.main[0].default_hostname, null)
  linux_webapp_url   = try(azurerm_linux_web_app.main[0].default_hostname, null)
}
locals {
  enable_github_sc = (
    var.webapp_object.github_token != null && var.webapp_object.github_token != "" &&
    var.webapp_object.Github != null && var.webapp_object.Github.repoUrl != ""
  )
}
