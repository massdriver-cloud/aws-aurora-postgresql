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

  final_snapshot_identifier = "${var.md_metadata.name_prefix}-final-${element(concat(random_id.snapshot_identifier.*.hex, [""]), 0)}"

  is_serverless                         = var.database.instance_class == "db.serverless"
  has_source_snapshot                   = var.database.source_snapshot != null
  performance_insights_retention_period = lookup(var.observability, "performance_insights_retention_period", 0)
  enable_performance_insights           = local.performance_insights_retention_period > 0
  enable_enhanced_monitoring            = lookup(var.observability, "enhanced_monitoring_interval", 0) > 0
}
