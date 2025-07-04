# ─────────────────────────────────────────────────────────────
#  INPUT OBJECT  ▸  now validates ISO-8601 TTL strings
# ─────────────────────────────────────────────────────────────
variable "bus_object" {
  description = "One Service-Bus namespace definition"
  type = object({
    Name  = string
    Env   = string

    Topics = optional(list(object({
      name          = string
      MaxTopicSize  = number
      MessageTTL    = string  # ISO-8601 like P14D, PT2H
    })), [])

    Queues = optional(list(object({
      name             = string
      MaxDeliveryCount = number
      MessageTTL       = string  # ISO-8601
    })), [])
  })

  validation {
    condition = alltrue(flatten([
      [for t in coalesce(var.bus_object.Topics, []) : can(regex("^P|PT", t.MessageTTL))],
      [for q in coalesce(var.bus_object.Queues, []) : can(regex("^P|PT", q.MessageTTL))]
    ]))
    error_message = "MessageTTL must be a valid ISO-8601 duration (e.g. P14D, PT2H)."
  }
}

variable "location" {
  type        = string
  description = "Azure region for Service-Bus resources"
  default     = "centralus"
}
