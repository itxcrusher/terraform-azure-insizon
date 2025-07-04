variable "Database_object" {
  description = "Database config"
  type = object({
    AppName           = string
    AppEnvironment    = string
    Rg_Location       = string
    Rg_Name           = string

    Type              = string               # "SQL" | "PostgreSQL"
    ServerAdminLogin  = string
    Password          = optional(string, "") # empty → auto-generate
    Sku               = string
    SizeGB            = number
    Collation         = optional(string, "SQL_Latin1_General_CP1_CI_AS")
    EnclaveType       = optional(string, "Default")
    LicenseType       = optional(string, "LicenseIncluded")
  })

  validation {
    # simple SKU allow-list check
    condition     = contains([
      "GP_S_Gen5_2","HS_Gen4_1","BC_Gen5_2","ElasticPool",
      "Basic","S0","P2","DW100c","DS100"
    ], var.Database_object.Sku)
    error_message = "Unsupported SKU name."
  }
}
