################################################################################
# locals.tf ── derived names, tags, look-ups
################################################################################

locals {
  # Base slug
  bus_name = "${var.bus_object.Name}-${var.bus_object.Env}"

  # Namespace name must be ≤50 chars and cannot contain underscores.
  ns_name = substr(replace("${local.bus_name}-ns", "_", "-"), 0, 50)

  # Resource-group unique to this namespace (easy tear-down).
  rg_name = "${local.bus_name}-sb-rg"

  sku = var.bus_object.Sku

  tags = {
    Environment = var.bus_object.Env
    Application = var.bus_object.Name
    Module      = "service_bus"
    ManagedBy   = "Terraform"
  }

  # Convert lists → maps for for_each convenience.
  topics_map = { for t in var.bus_object.Topics : t.name => t }
  queues_map = { for q in var.bus_object.Queues : q.name => q }
}