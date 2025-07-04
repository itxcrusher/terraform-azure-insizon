resource "azurerm_storage_blob" "upload" {
  for_each                = { for p in local.include_files : p => p }

  name                    = each.value
  source                  = "${local.src_folder}/${each.value}"
  storage_account_name    = azurerm_storage_account.sa.name
  storage_container_name  = azurerm_storage_container.container.name
  type                    = "Block"

  content_md5             = filebase64sha256("${local.src_folder}/${each.value}")
  content_type            = lookup(
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
