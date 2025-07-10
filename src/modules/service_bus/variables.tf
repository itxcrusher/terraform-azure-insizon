################################################################################
# variables.tf ─ Service-Bus module inputs
################################################################################

variable "bus_objects" {
  description = "List of Service Bus definitions for one environment"
  type = list(object({
    Name = string
    Env  = string
    Sku  = optional(string, "Standard")

    Topics = optional(list(object({
      name         = string
      MaxTopicSize = number
      MessageTTL   = string
    })), [])

    Queues = optional(list(object({
      name             = string
      MaxDeliveryCount = number
      MessageTTL       = string
    })), [])
  }))
}

variable "location" {
  description = "Azure region for all Service-Bus resources."
  type        = string
  default     = "centralus"
}
