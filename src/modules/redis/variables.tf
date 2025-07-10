variable "create_service" {
  description = "Whether to create the Redis cache"
  type        = bool
  default     = false
}

variable "name_prefix" {
  description = "Prefix for the Redis cache name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "RG that will hold the Redis cache"
  type        = string
}

variable "sku_name" {
  description = "SKU tier (Basic | Standard | Premium)"
  type        = string
  default     = "Basic"
}

variable "capacity" {
  description = "Shard size (0-6)"
  type        = number
  default     = 0
}

variable "family" {
  description = "Family code (C for Basic/Std, P for Premium)"
  type        = string
  default     = "C"
}

variable "non_ssl_port_enabled" {
  description = "Open the plaintext (non-TLS) port 6379 — discouraged"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
