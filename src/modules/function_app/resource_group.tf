resource "azurerm_resource_group" "fa_rg" {
  name     = substr("${local.app_name}-fa-rg", 0, 90)
  location = var.location
  tags     = local.tags
}
