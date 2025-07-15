variable "name" {
  description = "Display-name prefix for the app/SPN (e.g. temp-devops-7d)"
  type        = string
}

variable "ttl_hours" {
  description = "Lifetime of the client secret in hours"
  type        = number
  default     = 168 # 7 days
}

variable "role_name" {
  description = "Azure role to grant (Owner, Contributor, Reader …)"
  type        = string
  default     = "Reader"
}

variable "role_scopes" {
  description = "List of Azure resource IDs that define scope"
  type        = list(string)
}

variable "tenant_id" {
  description = "Azure AD tenant GUID"
  type        = string
}
