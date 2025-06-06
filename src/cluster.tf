resource "aws_rds_cluster" "main" {
  engine      = "aurora-postgresql"
  engine_mode = "provisioned"

  ## Database
  cluster_identifier          = var.md_metadata.name_prefix
  allow_major_version_upgrade = true

  master_username     = local.has_source_snapshot ? null : random_pet.root_username[0].id
  master_password     = random_password.root_password.result
  apply_immediately   = true
  engine_version      = var.database.version
  deletion_protection = var.database.deletion_protection
  snapshot_identifier = lookup(var.database, "source_snapshot", null)

  ## Networking
  db_subnet_group_name   = aws_db_subnet_group.main.name
  port                   = local.postgresql.port
  vpc_security_group_ids = [aws_security_group.main.id]
  network_type           = "IPV4"

  ## Storage
  storage_encrypted = true
  kms_key_id        = data.aws_kms_alias.postgresql.target_key_arn

  ## Backups & Snapshots
  skip_final_snapshot       = var.backup.skip_final_snapshot
  final_snapshot_identifier = var.backup.skip_final_snapshot ? null : local.final_snapshot_identifier
  backup_retention_period   = var.backup.retention_period
  copy_tags_to_snapshot     = true

  ## Observability
  enabled_cloudwatch_logs_exports = var.observability.enable_cloudwatch_logs_export ? ["postgresql"] : []

  # db_cluster_parameter_group_name - (Optional) A cluster parameter group to associate with the cluster.
  # db_instance_parameter_group_name - (Optional) Instance parameter group to associate with all instances of the DB cluster. The db_instance_parameter_group_name parameter is only valid in combination with the allow_major_version_upgrade parameter.

  dynamic "serverlessv2_scaling_configuration" {
    for_each = local.is_serverless ? [1] : []
    content {
      min_capacity = local.serverless_scaling.min_capacity
      max_capacity = local.serverless_scaling.max_capacity
    }
  }
}
