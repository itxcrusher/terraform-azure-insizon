# Core variables passed via tfvars per environment

variable "client_id" {
  type        = string
  description = "Azure client ID for Terraform service principal"
}

variable "client_secret" {
  type        = string
  description = "Azure client secret for Terraform service principal"
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

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

variable "DB_PASSWORD" {
  description = "Database admin password to inject into config"
  type        = string
  sensitive   = true
}
