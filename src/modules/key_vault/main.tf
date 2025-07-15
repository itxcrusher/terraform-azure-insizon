# ─────────────────────────────────────────────────────────────
#  KEY VAULT RESOURCE
# ─────────────────────────────────────────────────────────────
resource "azurerm_key_vault" "this" {
  name                = local.kv_name
  location            = var.keyvault_object.Rg_Location
  resource_group_name = var.keyvault_object.Rg_Name
  tenant_id           = var.keyvault_object.TenantId

  # allowed_tenant_ids = ["72f988bf-86f1-41af-91ab-2d7cd011db47", "b4ab6995-655a-4ae2-8de1-a1ae7849462f"]

  enable_rbac_authorization   = true
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = var.enable_purge_protection
  enabled_for_disk_encryption = true

  tags = local.tags_base
}

# ─────────────────────────────────────────────────────────────
#  KEY VAULT DIAGNOSTICS
# ─────────────────────────────────────────────────────────────
resource "azurerm_monitor_diagnostic_setting" "keyvault_logs" {
  count = var.log_analytics_workspace_id != "" ? 1 : 0

  name                       = "diag-${local.kv_name}"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }
}

# ─────────────────────────────────────────────────────────────
#  DYNAMIC RBAC ASSIGNMENTS
# ─────────────────────────────────────────────────────────────
resource "azurerm_role_assignment" "kv_rbac" {
  for_each = {
    for pa in local.principal_assignments :
    "${pa.principal_id}-${pa.role}" => pa
  }

  scope                = azurerm_key_vault.this.id
  role_definition_name = each.value.role
  principal_id         = each.value.principal_id
  principal_type       = each.value.principal_type
}

# ─────────────────────────────────────────────────────────────
#  SECRET  UPLOADS
# ─────────────────────────────────────────────────────────────
resource "azurerm_key_vault_secret" "secrets" {
  for_each = local.secrets_map

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.this.id

  # Optional – mark blobs vs creds
  content_type = length(each.value) > 50 ? "application/octet-stream" : "text/plain"

  lifecycle {
    # Guard against >25 KB (Azure limit)
    precondition {
      condition     = length(each.value) < 25000
      error_message = "Secret ${each.key} exceeds 25 KB Azure limit."
    }
  }
}
