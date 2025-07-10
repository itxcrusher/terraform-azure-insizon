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
  use_cdn = try(var.webapp_object.UseCDN, false)

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

  custom_domain_enabled = var.webapp_object.CustomDomain != null
  zone_managed = custom_domain_enabled && try(var.webapp_object.CustomDomain.managed_by_azure, false)

  dns_zone_name = zone_managed ? var.webapp_object.CustomDomain.ZoneName : null
  dns_zone_rg   = zone_managed ? var.webapp_object.CustomDomain.DnsZoneRG : null
  use_managed_cert = custom_domain_enabled && try(var.webapp_object.CustomDomain.UseManagedCert, true)

  custom_domain = (
    custom_domain_enabled ? var.webapp_object.CustomDomain.URL : null
  )
}
