###############################################################################
#  Canonical names & basic switches
###############################################################################
locals {
  # ---------- Naming ----------
  app_name        = "${var.function_object.Name}-${var.function_object.Env}"
  os_type_lower   = lower(var.function_object.Hosting.Type) # linux | windows
  os_type_title   = title(local.os_type_lower)              # Linux | Windows
  plan_type_lower = lower(var.function_object.Hosting.Plan)
  runtime_lang    = lower(var.function_object.Runtime.Language)
  runtime_ver     = var.function_object.Runtime.Version

  # ---------- Optional toggles ----------
  enable_ai    = var.function_object.CreateAppInsight
  enable_logic = var.function_object.CreateLogicApp

  # ---------- Tags ----------
  tags = {
    Environment = var.function_object.Env
    Application = var.function_object.Name
    Module      = "function_app"
    ManagedBy   = "Terraform"
  }
}

###############################################################################
#  Storage-account helper (3-24 lower-alnum chars)
###############################################################################
locals {
  storage_base = lower(substr(replace(local.app_name, "-", ""), 0, 18))
  storage_name = substr("${local.storage_base}${random_id.storage_suffix.hex}", 0, 24)
}

###############################################################################
#  GitHub source-control helpers  (safe, trimmed values)
###############################################################################
locals {
  # ---- Raw values directly from the object (may be null/blank) ----
  raw_repo_url   = try(var.function_object.Github.repoUrl, "")
  raw_branch     = try(var.function_object.Github.branch, "")
  raw_pat_token  = try(var.function_object.Github.token, "") # token in YAML (rare)
  raw_pat_inject = try(var.function_object.github_token, "") # token injected by root locals

  # ---- Trim & coalesce (null-safe) ----
  repo_url_safe = trimspace(coalesce(local.raw_repo_url, ""))
  branch_safe   = trimspace(coalesce(local.raw_branch, var.function_object.Env))
  token_safe    = trimspace(coalesce(local.raw_pat_token, local.raw_pat_inject, ""))

  # ---- “Should Terraform create azurerm_app_service_source_control?” ----
  enable_github_sc = (
    local.token_safe != "" &&
    local.repo_url_safe != "" &&
    local.branch_safe != ""
  )
}

###############################################################################
#  Plan SKU map
###############################################################################
locals {
  plan_sku = {
    consumption      = "Y1"
    flexconsumption  = "Y2"
    appservice_win   = "B1"
    appservice_linux = "B1"
  }
}

###############################################################################
#  IDs & URLs for whichever Function-App variant is created
###############################################################################
locals {
  windows_fa_id  = try(azurerm_windows_function_app.fa_win[0].id, null)
  linux_fa_id    = try(azurerm_linux_function_app.fa_linux[0].id, null)
  windows_fa_url = try(azurerm_windows_function_app.fa_win[0].default_hostname, null)
  linux_fa_url   = try(azurerm_linux_function_app.fa_linux[0].default_hostname, null)
}
