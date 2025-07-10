output "redis_hostname" {
  value       = length(azurerm_redis_cache.this) > 0 ? azurerm_redis_cache.this[0].hostname : null
  description = "Redis DNS name"
}

output "redis_ssl_port" {
  value       = length(azurerm_redis_cache.this) > 0 ? azurerm_redis_cache.this[0].ssl_port : null
  description = "TLS port"
}

output "primary_key" {
  value       = length(azurerm_redis_cache.this) > 0 ? azurerm_redis_cache.this[0].primary_access_key : null
  description = "Primary access key (sensitive)"
  sensitive   = true
}
