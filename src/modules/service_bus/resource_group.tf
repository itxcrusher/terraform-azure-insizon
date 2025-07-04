resource "azurerm_resource_group" "sb_rg" {
  name     = local.rg_name
  location = var.location
  tags     = local.tags
}
