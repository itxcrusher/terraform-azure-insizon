resource "azurerm_storage_account" "sa" {
  name                     = local.sa_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # allow_blob_public_access is not supported in this provider version.
  min_tls_version          = "TLS1_2"

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  # Uncomment if you plan to serve static-website directly (not via CDN)
  # static_website {
  #   index_document = "index.html"
  #   error_404_document = "404.html"
  # }

  tags = local.tags
}
