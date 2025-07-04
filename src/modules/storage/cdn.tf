resource "azurerm_cdn_profile" "profile" {
  count               = var.file_object.create_cdn ? 1 : 0
  name                = "${local.sa_name}-cdn"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "global"
  sku                 = "Standard_Microsoft"
  tags                = local.tags
}

resource "azurerm_cdn_endpoint" "endpoint" {
  count               = var.file_object.create_cdn ? 1 : 0
  name                = "${local.sa_name}-endpoint"
  profile_name        = azurerm_cdn_profile.profile[0].name
  resource_group_name = azurerm_resource_group.rg.name
  location            = "global"

  origin {
    name      = "blob-origin"
    host_name = trimsuffix(azurerm_storage_account.sa.primary_blob_endpoint, "/")
  }
}
