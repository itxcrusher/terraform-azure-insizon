resource "azurerm_dns_cname_record" "webapp_cname" {
  count               = local.zone_managed ? 1 : 0
  name                = trimsuffix(local.custom_domain, ".${local.dns_zone_name}")
  zone_name           = local.dns_zone_name
  resource_group_name = local.dns_zone_rg
  ttl                 = 300

  record              = local.windows_webapp_url != null ? local.windows_webapp_url : local.linux_webapp_url
}

resource "azurerm_app_service_custom_hostname_binding" "domain" {
  count               = local.custom_domain_enabled ? 1 : 0
  hostname            = local.custom_domain
  app_service_name    = local.os_type == "windows" ? azurerm_windows_web_app.main[0].name : azurerm_linux_web_app.main[0].name
  resource_group_name = azurerm_resource_group.main.name

  depends_on = [
    azurerm_dns_cname_record.webapp_cname
  ]
}

resource "azurerm_dns_txt_record" "asuid_validation" {
  count               = local.zone_managed && local.use_managed_cert ? 1 : 0
  name                = "asuid.${trimsuffix(local.custom_domain, ".${local.dns_zone_name}")}"
  zone_name           = local.dns_zone_name
  resource_group_name = local.dns_zone_rg
  ttl                 = 300

  record {
    value = azurerm_app_service_custom_hostname_binding.domain[0].validation_token
  }

  depends_on = [
    azurerm_app_service_custom_hostname_binding.domain
  ]
}

resource "azurerm_app_service_managed_certificate" "domain_tls" {
  count               = local.zone_managed && local.use_managed_cert ? 1 : 0
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.domain[0].id
}
