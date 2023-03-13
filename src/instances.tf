locals {
  # TODO: don't differentiate, max 16; n+1 ... otherwise the 'primary' could become a 'replica' during an outage...
  instances = [
    { 1 = {} },
    { 2 = {} },
  ]
}

resource "aws_rds_cluster_instance" "instance" {
  for_each = { for k, v in local.instances : k => v }

  cluster_identifier         = aws_rds_cluster.main.id
  identifier_prefix          = "${var.md_metadata.name_prefix}-instance-"
  engine                     = aws_rds_cluster.main.engine
  engine_version             = aws_rds_cluster.main.engine_version
  db_subnet_group_name       = aws_db_subnet_group.main.name
  copy_tags_to_snapshot      = true
  apply_immediately          = true
  publicly_accessible        = false
  auto_minor_version_upgrade = false

  instance_class     = var.database.instance_class
  ca_cert_identifier = var.database.ca_cert_identifier

  monitoring_role_arn = local.enable_enhanced_monitoring ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
  monitoring_interval = var.observability.enhanced_monitoring_interval

  performance_insights_enabled          = local.enable_performance_insights
  performance_insights_kms_key_id       = local.enable_performance_insights ? data.aws_kms_alias.postgresql.target_key_arn : null
  performance_insights_retention_period = local.enable_performance_insights ? local.performance_insights_retention_period : null

  # TODO:
  # db_parameter_group_name = var.create_db_parameter_group ? aws_db_parameter_group.this[0].id : var.db_parameter_group_name
}
