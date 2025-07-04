variable "webapp_object" {
  description = "Full configuration for a single web app"
  type = object({
    Name               = string
    Env                = string
    Location           = optional(string, "centralus")
    OsType             = optional(string, "Windows")
    Sku                = optional(string, "D1")
    DotnetVersion      = optional(string, "v8.0")
    NodeVersion        = optional(string, "")     # used for Linux
    AlwaysOn           = optional(bool, false)

    CreateAppInsight   = optional(bool, false)
    CreateLogicApp     = optional(bool, false)

    Github = optional(object({
      repoUrl = string
      token   = string
      branch  = optional(string)
    }), null)

    github_token = optional(string)

    CustomDomain = optional(object({
      URL = string
    }), null)

    StorageAccount = optional(list(string), [])

    Database = optional(object({
      Type              = string   # SQL or PostgreSQL
      ServerAdminLogin = string
      Password          = string
      Sku               = string
      SizeGB            = number
    }), null)

    ObjectId = string
    TenantId = string
  })
}
