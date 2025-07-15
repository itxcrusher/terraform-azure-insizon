variable "display_name" {
  type        = string
  description = "Display name for the Azure AD App"
}

variable "owner_ids" {
  type        = list(string)
  description = "List of Entra user object IDs"
}

variable "redirect_uris" {
  type    = list(string)
  default = []
}

variable "app_roles" {
  description = "Optional list of app roles"
  type = list(object({
    allowed_member_types = list(string)
    description          = string
    display_name         = string
    is_enabled           = bool
    value                = string
    id                   = string # must be UUID
  }))
  default = []
}
