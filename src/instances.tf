resource "aws_rds_cluster_instance" "instance" {
  for_each = { for k, v in local.instance_configs : k => v }

  cluster_identifier         = aws_rds_cluster.main.id
  identifier_prefix          = "${var.md_metadata.name_prefix}-"
  engine                     = aws_rds_cluster.main.engine
  engine_version             = aws_rds_cluster.main.engine_version
  db_subnet_group_name       = aws_db_subnet_group.main.name
  copy_tags_to_snapshot      = true
  apply_immediately          = true
  publicly_accessible        = false
  auto_minor_version_upgrade = false

  instance_class     = var.database.instance_class
  ca_cert_identifier = var.database.ca_cert_identifier

  monitoring_role_arn = local.enhanced_monitoring_enabled ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
  monitoring_interval = var.observability.enhanced_monitoring_interval

  performance_insights_enabled          = local.performance_insights_enabled
  performance_insights_kms_key_id       = local.performance_insights_enabled ? data.aws_kms_alias.postgresql.target_key_arn : null
  performance_insights_retention_period = local.performance_insights_enabled ? local.performance_insights_retention_period : null

  # TODO:
  # db_parameter_group_name = var.create_db_parameter_group ? aws_db_parameter_group.this[0].id : var.db_parameter_group_name
}
