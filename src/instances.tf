locals {
  # TODO: ditch for autoscaling, set count to min of autoscaling for replicas.
  # split into two resources: primary & replicas
  instances = [
    { 1 = {} },
    { 2 = {} },
  ]
}

resource "aws_rds_cluster_instance" "instance" {
  for_each = { for k, v in local.instances : k => v }

  cluster_identifier    = aws_rds_cluster.main.id
  identifier_prefix     = "${var.md_metadata.name_prefix}-instance-"
  engine                = aws_rds_cluster.main.engine
  engine_version        = aws_rds_cluster.main.engine_version
  db_subnet_group_name  = aws_db_subnet_group.main.name
  copy_tags_to_snapshot = true
  apply_immediately     = true
  publicly_accessible   = false

  # TODO: field? how does an old value effect this? on redeploy?
  auto_minor_version_upgrade = false

  instance_class     = var.database.instance_class
  ca_cert_identifier = var.database.ca_cert_identifier

  monitoring_role_arn = local.enhanced_monitoring_enabled ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
  monitoring_interval = var.observability.enhanced_monitoring_interval

  # TODO:
  # performance_insights_enabled          = try(each.value.performance_insights_enabled, var.performance_insights_enabled)
  # performance_insights_kms_key_id       = try(each.value.performance_insights_kms_key_id, var.performance_insights_kms_key_id)
  # performance_insights_retention_period = try(each.value.performance_insights_retention_period, var.performance_insights_retention_period)
  # db_parameter_group_name = var.create_db_parameter_group ? aws_db_parameter_group.this[0].id : var.db_parameter_group_name
}
