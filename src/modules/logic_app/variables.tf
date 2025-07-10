variable "create_logic_app" {
  type        = bool
  description = "Whether to create Logic App"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for naming the Logic App"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for Logic App"
}

variable "definition" {
  description = "Logic App workflow definition JSON"
  type        = any
  default     = {}
}

variable "tags" {
  type = map(string)
}
