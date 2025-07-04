locals {
  # Canonical names
  app_name  = "${var.function_object.Name}-${var.function_object.Env}"

  os_type_lower  = lower(var.function_object.Hosting.Type)     # linux | windows
  os_type_title  = title(local.os_type_lower)                  # Linux | Windows
  plan_type_lower = lower(var.function_object.Hosting.Plan)

  runtime_lang = lower(var.function_object.Runtime.Language)
  runtime_ver  = var.function_object.Runtime.Version

  enable_ai    = var.function_object.CreateAppInsight
  enable_logic = var.function_object.CreateLogicApp

  git_repo_url = var.function_object.Github != null ? var.function_object.Github.repoUrl : null
  git_branch   = try(var.function_object.Github.branch, var.function_object.Env)

  tags = {
    Environment = var.function_object.Env
    Application = var.function_object.Name
    Module      = "function_app"
    ManagedBy   = "Terraform"
  }
}

# Storage account name must be 3-24 lowercase letters/numbers, no dashes.
locals {
  storage_base = lower(substr(replace(local.app_name, "-", ""), 0, 18))
  storage_name = substr("${local.storage_base}${random_id.storage_suffix.hex}", 0, 24)
}
