resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.file_object.location
  tags     = local.tags
}

resource "azurerm_storage_container" "container" {
  name                  = local.container_name
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

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
    name       = "blob-origin"
    host_name  = "${azurerm_storage_account.sa.name}.blob.core.windows.net"
    https_port = 443
  }

  depends_on = [azurerm_storage_account_static_website.web]
}

resource "azurerm_cdn_endpoint_custom_domain" "cdn_domain" {
  count           = var.file_object.create_cdn && local.custom_domain_enabled ? 1 : 0
  name            = replace(var.file_object.custom_domain, ".", "-")
  cdn_endpoint_id = azurerm_cdn_endpoint.endpoint[0].id
  host_name       = var.file_object.custom_domain
  depends_on      = [azurerm_storage_account_static_website.web]
}

resource "azurerm_storage_account" "sa" {
  name                     = local.sa_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    # Azure no longer supports "AzureFrontDoorService", "MicrosoftCDN" in the bypass field
    # Enable traffic from Front Door / CDN via IP ranges or service tags
    # ip_rules = []
  }

  tags = local.tags
}

resource "azurerm_storage_account_static_website" "web" {
  count              = var.enable_static_website ? 1 : 0
  storage_account_id = azurerm_storage_account.sa.id

  index_document     = var.static_website_index != null ? var.static_website_index : fileexists("${local.src_folder}/index.html") ? "index.html" : null
  error_404_document = var.error_404_document != null ? var.error_404_document : fileexists("${local.src_folder}/404.html") ? "404.html" : null
}

resource "azurerm_storage_blob" "upload" {
  for_each = { for p in local.include_files : p => p }

  name                   = each.value
  source                 = "${local.src_folder}/${each.value}"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"

  content_md5 = base64encode(md5(file("${local.src_folder}/${each.value}")))
  content_type = lookup(
    { # tiny MIME map
      "html" = "text/html",
      "css"  = "text/css",
      "js"   = "application/javascript",
      "png"  = "image/png",
      "jpg"  = "image/jpeg",
      "jpeg" = "image/jpeg",
      "svg"  = "image/svg+xml"
    },
    lower(regex("[^.]+$", each.value)),
    "application/octet-stream"
  )
  cache_control = "public, max-age=31536000"
}
