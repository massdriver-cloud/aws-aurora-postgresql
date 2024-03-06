locals {
  vpc_id = element(split("/", var.vpc.data.infrastructure.arn), 1)

  postgresql = {
    protocol = "tcp"
    port     = 5432
  }

  subnet_ids = {
    "internal" = [for subnet in var.vpc.data.infrastructure.internal_subnets : element(split("/", subnet["arn"]), 1)]
    "private"  = [for subnet in var.vpc.data.infrastructure.private_subnets : element(split("/", subnet["arn"]), 1)]
  }

  is_serverless                         = var.database.instance_class == "db.serverless"
  has_source_snapshot                   = lookup(var.database, "source_snapshot", null) != null
  final_snapshot_identifier             = "${var.md_metadata.name_prefix}-final-${element(concat(random_id.snapshot_identifier.*.hex, [""]), 0)}"
  performance_insights_retention_period = lookup(var.observability, "performance_insights_retention_period", 0)
  performance_insights_enabled          = local.performance_insights_retention_period > 0
  enhanced_monitoring_enabled           = lookup(var.observability, "enhanced_monitoring_interval", 0) > 0
  autoscaling_enabled                   = var.availability.autoscaling_mode != "DISABLED"

  default_serverless_scaling = {
    min_capacity = 0.5
    max_capacity = 1.0
  }

  effective_serverless_scaling = merge(
    local.default_serverless_scaling,
    var.database.serverless_scaling != null ? var.database.serverless_scaling : {}
  )

  # Primary + Replicas
  # We don't differentiate the primary as a terraform resource in the event that their is a failover
  # AWS will promote a replica. By not differentiating the naming/tf resource we avoid
  # weird state like a primary named "foo-replica-3"
  total_instances  = var.availability.min_replicas + 1
  instance_configs = { for i in range(local.total_instances) : "${i}" => {} }
}
