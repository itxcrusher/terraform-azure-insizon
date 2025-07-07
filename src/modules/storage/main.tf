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
    name      = "blob-origin"
    host_name = trimsuffix(azurerm_storage_account.sa.primary_blob_endpoint, "/")
  }
}

resource "azurerm_storage_account" "sa" {
  name                     = local.sa_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # allow_blob_public_access is not supported in this provider version.
  min_tls_version = "TLS1_2"

  network_rules {
    default_action             = var.file_object.create_cdn ? "Deny" : "Allow"
    bypass                     = ["AzureServices"]
    ip_rules                   = var.file_object.create_cdn ? ["0.0.0.0/0"] : []
    virtual_network_subnet_ids = []
  }

  # Uncomment if you plan to serve static-website directly (not via CDN)
  # static_website {
  #   index_document = "index.html"
  #   error_404_document = "404.html"
  # }

  tags = local.tags
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
}
