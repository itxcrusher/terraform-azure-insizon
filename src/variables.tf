# Core variables passed via tfvars per environment
variable "app_environment" {
  type        = string
  description = "The environment to deploy to (dev, qa, prod)"
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "client_id" {
  type        = string
  description = "Azure client ID for Terraform service principal"
}

variable "client_secret" {
  type        = string
  description = "Azure client secret for Terraform service principal"
}

# Optional GitHub token (can also be passed via secrets manager or env vars)
variable "github_token" {
  type        = string
  description = "GitHub personal access token for private repo access"
  sensitive   = true
  default     = ""
}
