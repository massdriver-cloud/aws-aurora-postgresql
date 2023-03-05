resource "aws_rds_cluster" "main" {
  engine      = "aurora-postgresql"
  engine_mode = "provisioned"

  ## Database
  cluster_identifier          = var.md_metadata.name_prefix
  allow_major_version_upgrade = true
  master_username             = random_pet.root_username.id
  master_password             = random_password.root_password.result
  apply_immediately           = true
  engine_version              = var.database.version
  database_name               = var.database.name
  deletion_protection         = var.database.deletion_protection

  ## Networking
  db_subnet_group_name   = aws_db_subnet_group.main.name
  port                   = local.postgresql.port
  vpc_security_group_ids = [aws_security_group.main.id]
  network_type           = "IPV4"

  ## Storage
  storage_encrypted = true
  # TODO: WHICH GODDAMN ID
  # kms_key_id             = data.aws_kms_alias.postgresql.target_key_arn

  ## Backups & Snapshots
  skip_final_snapshot       = var.backup.skip_final_snapshot
  final_snapshot_identifier = var.backup.skip_final_snapshot ? null : local.final_snapshot_identifier
  backup_retention_period   = var.backup.retention_period
  copy_tags_to_snapshot     = true

  ## Observability
  enabled_cloudwatch_logs_exports = var.observability.enable_cloudwatch_logs_export ? ["postgresql"] : []


  # backtrack_window - (Optional) The target backtrack window, in seconds. Only available for aurora and aurora-mysql engines currently. To disable backtracking, set this value to 0. Defaults to 0. Must be between 0 and 259200 (72 hours)

  # db_cluster_parameter_group_name - (Optional) A cluster parameter group to associate with the cluster.

  # db_instance_parameter_group_name - (Optional) Instance parameter group to associate with all instances of the DB cluster. The db_instance_parameter_group_name parameter is only valid in combination with the allow_major_version_upgrade parameter.

  # iam_database_authentication_enabled - (Optional) Specifies whether or not mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled. Please see AWS Documentation for availability and limitations.

  # kms_key_id - (Optional) The ARN for the KMS encryption key. When specifying kms_key_id, storage_encrypted needs to be set to true.

  # preferred_backup_window - (Optional) The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC. Default: A 30-minute window selected at random from an 8-hour block of time per regionE.g., 04:00-09:00

  # preferred_maintenance_window - (Optional) The weekly time range during which system maintenance can occur, in (UTC) e.g., wed:04:00-wed:04:30

  # restore_to_point_in_time - (Optional) Nested attribute for point in time restore. More details below.

  # serverlessv2_scaling_configuration- (Optional) Nested attribute with scaling properties for ServerlessV2. Only valid when engine_mode is set to provisioned. More details below.

  # snapshot_identifier - (Optional) Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot.
  # https://docs.massdriver.cloud/runbook/aws/migrating-rds-databases

  # storage_encrypted - (Optional) Specifies whether the DB cluster is encrypted. The default is false for provisioned engine_mode and true for serverless engine_mode. When restoring an unencrypted snapshot_identifier, the kms_key_id argument must be provided to encrypt the restored cluster. Terraform will only perform drift detection if a configuration value is provided.

  # conditional based on instance class
  serverlessv2_scaling_configuration {
    min_capacity = 2
    max_capacity = 10
  }
}
