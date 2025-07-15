################################################################################
# locals.tf ── derived names, tags, look-ups
################################################################################

locals {
  # Grouped buses per name for looping
  bus_map = {
    for bus in var.bus_objects : "${bus.Name}-${bus.Env}" => bus
  }

  rg_name = "sb-${var.bus_objects[0].Env}-rg"

  tags = {
    Environment = var.bus_objects[0].Env
    Module      = "service_bus"
    ManagedBy   = "Terraform"
  }

  # Topics
  all_topics = flatten([
    for bus in var.bus_objects : [
      for t in bus.Topics : {
        key     = "${bus.Name}-${t.name}"
        topic   = t
        ns_name = "${bus.Name}-${bus.Env}-ns"
        app_key = try(t.TargetApp, null)
      }
    ]
  ])

  topics_map = { for t in local.all_topics : t.key => t }

  # Queues
  all_queues = flatten([
    for bus in var.bus_objects : [
      for q in bus.Queues : {
        key     = "${bus.Name}-${q.name}"
        queue   = q
        ns_name = "${bus.Name}-${bus.Env}-ns"
        app_key = try(q.TargetApp, null)
      }
    ]
  ])

  queues_map = { for q in local.all_queues : q.key => q }
}
