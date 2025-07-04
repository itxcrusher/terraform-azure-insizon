# ─────────────────────────────────────────────────────────────
#  KEY VAULT RESOURCE
# ─────────────────────────────────────────────────────────────
resource "azurerm_key_vault" "this" {
  name                        = local.kv_name
  location                    = var.keyvault_object.Rg_Location
  resource_group_name         = var.keyvault_object.Rg_Name
  tenant_id                   = var.keyvault_object.TenantId

  enable_rbac_authorization   = true
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = var.enable_purge_protection
  enabled_for_disk_encryption = true

  tags = local.tags_base
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
  for_each     = local.secrets_map

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.this.id
}
