variable "function_object" {
  description = "Config for one Azure Function App"
  type = object({
    Name = string
    Env  = string

    Hosting = object({
      Type = string               # Linux | Windows
      Plan = string               # Consumption | FlexConsumption | AppService
    })

    Runtime = object({
      Language = string           # node | python | dotnet | java | powershell
      Version  = string           # e.g. 18, 3.11, 8.0
    })

    CreateAppInsight = optional(bool, false)
    CreateLogicApp   = optional(bool, false)

    Github = optional(object({
      repoUrl = string
      token   = string
      branch  = optional(string)
    }), null)

    github_token = optional(string)
  })

  ### --- ENUM VALIDATIONS ---
  validation {
    condition     = contains(["linux", "windows"], lower(var.function_object.Hosting.Type))
    error_message = "Hosting.Type must be either 'Linux' or 'Windows'."
  }

  validation {
    condition     = contains(["consumption", "flexconsumption", "appservice"], lower(var.function_object.Hosting.Plan))
    error_message = "Hosting.Plan must be 'Consumption', 'FlexConsumption', or 'AppService'."
  }

  validation {
    condition = contains(
      ["node", "python", "dotnet", "java", "powershell"],
      lower(var.function_object.Runtime.Language)
    )
    error_message = "Runtime.Language must be one of node | python | dotnet | java | powershell."
  }
}

# Region selector for multi-region deployments
variable "location" {
  type        = string
  description = "Azure region for the Function App resources"
  default     = "centralus"
}
