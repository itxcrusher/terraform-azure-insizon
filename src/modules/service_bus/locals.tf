locals {
  bus_name = "${var.bus_object.Name}-${var.bus_object.Env}"

  # 50-char limit + sanitize underscores
  ns_name  = substr(replace("${local.bus_name}-ns", "_", "-"), 0, 50)
  rg_name  = "${local.bus_name}-sb-rg"

  tags = {
    Environment = var.bus_object.Env
    Application = var.bus_object.Name
    Module      = "service_bus"
    ManagedBy   = "Terraform"
  }

  topics_map = { for t in var.bus_object.Topics : t.name => t }
  queues_map = { for q in var.bus_object.Queues : q.name => q }
}
