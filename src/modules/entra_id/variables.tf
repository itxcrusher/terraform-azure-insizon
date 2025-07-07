# ─────────────────────────────────────────────────────────────
#  INPUTS
# ─────────────────────────────────────────────────────────────
variable "users_object" {
  description = "Map(username => user-spec from users.yaml)"
  type = map(object({
    fullName = string
    roles    = list(string)
    limit    = list(string) # zero-length => subscription scope
  }))
}

variable "subscription_id" {
  type        = string
  description = "Current subscription ID (for subscription-level role assignments)."
}

# YAML role labels -> Azure built-in role names
variable "roles_lookup" {
  type = map(string)
  default = {
    admin          = "Owner"
    developer      = "Contributor"
    readonly       = "Reader"
    auditor        = "Security Reader"
    serviceAccount = "Contributor"
  }
}

variable "password_length" {
  type    = number
  default = 20
}
