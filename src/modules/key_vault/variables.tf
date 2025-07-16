# ─────────────────────────────────────────────────────────────
#  INPUT OBJECT  –  100 % YAML-DRIVEN
# ─────────────────────────────────────────────────────────────
variable "keyvault_object" {
  description = <<EOT
App- and environment-scoped Key Vault definition.

additional_principals (optional) lets you inject any number of
{ principal_id, role, principal_type } triples – matching the
“limit user to specific RG” requirement.
EOT
  type = object({
    AppName        = string
    AppEnvironment = string
    Rg_Location    = string
    Rg_Name        = string
    TenantId       = string
    ObjectId       = string # primary SP / user running TF
    additional_principals = optional(list(object({
      principal_id   = string
      role           = string # e.g. Key Vault Secrets Officer
      principal_type = string # User | ServicePrincipal | Group
    })), [])
  })
}

# Optional override for secrets YAML folder
variable "secrets_yaml_rel_path" {
  type        = string
  default     = "private/key_vault_manager"
  description = "Relative path (from repo root) to secrets YAML."
}

# Default RBAC role for the primary principal
variable "default_primary_role" {
  type        = string
  default     = "Key Vault Administrator"
  description = "Role assigned to the main principal_id (ObjectId)."
}

# Enable / disable purge-protection (false for dev, true for prod)
variable "enable_purge_protection" {
  type        = bool
  default     = false
  description = "Set true to enforce purge protection on the vault."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the Log Analytics Workspace for diagnostic settings."
  default     = ""
}

variable "additional_principals" {
  description = "List of RBAC assignments for this Key Vault"
  type = list(object({
    principal_id   = string
    role           = string
    principal_type = string
  }))
  default = []
}
