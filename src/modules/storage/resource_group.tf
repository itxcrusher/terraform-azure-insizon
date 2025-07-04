resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.file_object.location
  tags     = local.tags
}
