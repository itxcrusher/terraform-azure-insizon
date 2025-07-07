# ─────────────────────────────────────────────────────────────
#  LOCALS – YAML → Terraform-friendly structures
# ─────────────────────────────────────────────────────────────
locals {
  kv_root_clean = lower(
    replace(
      "${var.keyvault_object.AppName}${var.keyvault_object.AppEnvironment}",
      "[^a-z0-9]",
      ""
    )
  )

  kv_name = "${substr(local.kv_root_clean, 0, 20)}${random_string.suffix.result}"

  # Absolute path to the secrets YAML
  secrets_yaml_abs = abspath(
    "${path.root}/${var.secrets_yaml_rel_path}/${var.keyvault_object.AppName}-${var.keyvault_object.AppEnvironment}-keyvault-manager.yaml"
  )

  # Decode YAML safely: if file missing → empty list
  secrets_map_raw = try(
    yamldecode(file(local.secrets_yaml_abs)).secrets,
    []
  )

  secrets_map = {
    for s in local.secrets_map_raw :
    s.key => tostring(s.value)
  }

  # RBAC list (primary + optional extras)
  principal_assignments = concat(
    [
      {
        principal_id   = var.keyvault_object.ObjectId
        role           = var.default_primary_role
        principal_type = "ServicePrincipal"
      }
    ],
    var.keyvault_object.additional_principals
  )

  tags_base = {
    Module      = "key_vault"
    Environment = var.keyvault_object.AppEnvironment
    ManagedBy   = "Terraform"
  }
}

resource "random_string" "suffix" {
  length  = 4
  lower   = true
  upper   = false
  numeric = true
  special = false
}
