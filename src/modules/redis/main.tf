resource "azurerm_redis_cache" "this" {
  count               = var.create_service ? 1 : 0

  name                = "${var.name_prefix}-redis"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name            = var.sku_name
  capacity            = var.capacity
  family              = var.family

  non_ssl_port_enabled = var.non_ssl_port_enabled

  minimum_tls_version = "1.2"

  tags = var.tags
}
