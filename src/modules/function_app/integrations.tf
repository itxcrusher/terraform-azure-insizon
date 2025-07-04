# ---------- GitHub Source Control (optional) ----------
# Only create if a repo URL AND a usable PAT exist
locals {
  effective_pat = (
    var.function_object.Github != null && trim(var.function_object.Github.token, "") != ""
      ? var.function_object.Github.token
      : trim(coalesce(var.function_object.github_token, ""), "")
  )
}

resource "azurerm_app_service_source_control" "github_fa" {
  count = local.git_repo_url != null && local.effective_pat != "" ? 1 : 0

  app_id                 = local.os_type_lower == "windows" ? azurerm_windows_function_app.fa_win[0].id : azurerm_linux_function_app.fa_linux[0].id

  repo_url               = local.git_repo_url
  branch                 = local.git_branch
  # personal_access_token is not supported in this provider version.
  use_manual_integration = true
}

# ---------- Logic App (optional) ----------
resource "azurerm_logic_app_workflow" "fa_logic" {
  count               = local.enable_logic ? 1 : 0
  name                = substr("${local.app_name}-logic", 0, 60)
  location            = azurerm_resource_group.fa_rg.location
  resource_group_name = azurerm_resource_group.fa_rg.name

  # definition attribute is not supported in this provider version. Logic App will be created without a workflow definition.

  tags = local.tags
}
