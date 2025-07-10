variable "webapp_object" {
  description = "Full configuration for a single web app"
  type = object({
    # ── existing fields ──────────────────────────────────────────
    Name              = string
    Env               = string
    Location          = optional(string, "centralus")
    OsType            = optional(string, "Windows")
    Sku               = optional(string, "D1")
    DotnetVersion     = optional(string, "v8.0")
    NodeVersion       = optional(string, "")
    AlwaysOn          = optional(bool, false)

    CreateAppInsight  = optional(bool, false)
    CreateLogicApp    = optional(bool, false)
    StorageAccount = optional(list(string), [])
    UseSas         = optional(bool, false)
    SasExpiryYears = optional(number, 10)
    UseCDN = optional(bool, false)

    CustomDomain = optional(object({
      URL              = string                     # required
      managed_by_azure = optional(bool, false)      # true → zone in Azure
      ZoneName         = optional(string)           # needed only if managed_by_azure = true
      DnsZoneRG        = optional(string)           #   "
      UseManagedCert   = optional(bool, true)
    }), null)    

    StorageConfig = optional(object({
      Tier               = optional(string, "Standard")
      Replication        = optional(string, "LRS")
      PublicAccess       = optional(bool, false)
      OnlyHttp           = optional(bool, true)
      PublicNestedItems  = optional(bool, false)
      MinTLSVersion      = optional(string, "TLS1_2")
    }), null)

    Database = optional(object({
      Type             = string
      ServerAdminLogin = string
      Password         = string
      Sku              = string
      SizeGB           = number
    }), null)

    # ── NEW: Redis block (fully optional) ────────────────────────
    Redis = optional(object({
      create_service       = optional(bool, false)
      sku_name             = optional(string, "Basic")
      capacity             = optional(number, 0)
      family               = optional(string, "C")
      enable_non_ssl_port  = optional(bool, false)
    }), null)

    ObjectId = string
    TenantId = optional(string)
    additional_principals = optional(list(object({
      principal_id   = string
      role           = string
      principal_type = string
    })), [])
  })
  validation {
    condition = (
      var.webapp_object.CustomDomain == null ||
      !contains(["F1", "D1", "Free_F1"], var.webapp_object.Sku)
    )
    error_message = "apps.yaml error: CustomDomain requires a paid App Service Plan (SKU B1 or higher)."
  }

  validation {
    condition = (
      var.webapp_object.AlwaysOn == false ||
      !contains(["F1", "D1", "Free_F1"], var.webapp_object.Sku)
    )
    error_message = "apps.yaml error: AlwaysOn cannot be true when using free/shared SKU (F1/D1)."
  }
}

variable "tenant_id" {
  description = "Tenant id from tfvars"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "Client ID from app registration"
  type        = string
}

variable "client_secret" {
  description = "Client secret from app registration"
  type        = string
  sensitive   = true
}

variable "law_id" {
  description = "ID of the Log Analytics Workspace (optional)"
  type        = string
  default     = ""
}
