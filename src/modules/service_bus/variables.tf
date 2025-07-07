################################################################################
# variables.tf ─ Service-Bus module inputs
################################################################################

# One object = one namespace. A higher-level caller iterates over a list/map.
# ISO-8601 duration validation is done inline so bad TTLs fail at plan-time.
variable "bus_object" {
  description = "Service-Bus namespace definition (see config YAML)."

  type = object({
    Name = string # logical app name, e.g. insizon-bus
    Env  = string # dev / qa / prod …

    # SKU: Basic | Standard | Premium (default Standard)
    Sku = optional(string, "Standard")

    # ── Top-level messaging entities ──────────────────────────────────────────
    Topics = optional(list(object({
      name         = string # topic name
      MaxTopicSize = number # 1024 → 81920 MB depending on SKU
      MessageTTL   = string # ISO-8601 duration (e.g. P14D)
    })), [])

    # ── Point-to-point queues ─────────────────────────────────────────────────
    Queues = optional(list(object({
      name             = string
      MaxDeliveryCount = number # DLQ threshold
      MessageTTL       = string # ISO-8601 duration
    })), [])
  })

  # Validate every TTL with a simple ISO-8601 regex
  validation {
    condition = alltrue(flatten([
      [for t in coalesce(var.bus_object.Topics, []) :
      can(regex("^P(\\d+D)?(T(\\d+H)?(\\d+M)?(\\d+S)?)?$", t.MessageTTL))],
      [for q in coalesce(var.bus_object.Queues, []) :
      can(regex("^P(\\d+D)?(T(\\d+H)?(\\d+M)?(\\d+S)?)?$", q.MessageTTL))]
    ]))
    error_message = "MessageTTL must be a valid ISO-8601 duration (e.g. P14D, PT2H)."
  }
}

variable "location" {
  description = "Azure region for all Service-Bus resources."
  type        = string
  default     = "centralus"
}