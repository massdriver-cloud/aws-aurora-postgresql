locals {
  // 128 tebibytes (TiB)
  _cluster_volume_bytes_max_tib               = 128
  _cluster_volume_bytes_max_bytes             = local._cluster_volume_bytes_max_tib * 1024 * 1024 * 1024 * 1024
  _cluster_volume_bytes_max_threshold         = 90
  _cluster_volume_bytes_max_threshold_percent = local._cluster_volume_bytes_max_threshold / 100.0
  automated_alarms = {
    cluster_volume_bytes_used = {
      period    = 300
      threshold = floor(local._cluster_volume_bytes_max_bytes * local._cluster_volume_bytes_max_threshold_percent)
      statistic = "Maximum"
    }
    acu_utilization = {
      period    = 300
      threshold = 90
      statistic = "Average"
    }
  }
  alarms_map = {
    "AUTOMATED" = local.automated_alarms
    "DISABLED"  = {}
    // "CUSTOM"    = lookup(var.monitoring, "alarms", {})
  }

  // No UI control supported yet.
  //alarms = lookup(local.alarms_map, var.monitoring.mode, {})
  alarms = local.alarms_map["AUTOMATED"]

  // CloudWatch notifications carry no resource tags, so Massdriver reads the instance from the description.
  alarm_instance = try({ "md-instance" = var.md_metadata.default_tags["md-instance"] }, { name_prefix = var.md_metadata.name_prefix })
}

module "alarm_channel" {
  source      = "massdriver-cloud/aws-alarm-channel/massdriver"
  version     = "~> 0.1.0"
  md_metadata = var.md_metadata
}

// Inlined instead of using the aws-metric-alarm module: module 1.x requires massdriver provider >= 2.0,
// which cannot read state written by 1.0.3 (massdriver_artifact / massdriver_package_alarm).
// Provider 1.4 knows both the old and new resource types, so it can destroy the old ones and create the new ones.
resource "aws_cloudwatch_metric_alarm" "cluster_volume_bytes_used" {
  count = lookup(local.alarms, "cluster_volume_bytes_used", null) == null ? 0 : 1

  alarm_name = "${aws_rds_cluster.main.cluster_identifier}-highClusterVolumeBytesUsed"
  alarm_description = jsonencode(merge(local.alarm_instance, {
    message = "RDS Aurora ${aws_rds_cluster.main.cluster_identifier}: Cluster Volume Bytes Used has exceeded ${local._cluster_volume_bytes_max_threshold}% of ${local._cluster_volume_bytes_max_tib}TiB"
  }))

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "VolumeBytesUsed"
  namespace           = "AWS/RDS"
  statistic           = local.alarms.cluster_volume_bytes_used.statistic
  period              = local.alarms.cluster_volume_bytes_used.period
  threshold           = local.alarms.cluster_volume_bytes_used.threshold

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.main.cluster_identifier
  }

  actions_enabled = true
  alarm_actions   = [module.alarm_channel.arn]
  ok_actions      = [module.alarm_channel.arn]
}

resource "massdriver_instance_alarm" "cluster_volume_bytes_used" {
  count = length(aws_cloudwatch_metric_alarm.cluster_volume_bytes_used)

  display_name        = "Cluster Volume Bytes Used"
  cloud_resource_id   = aws_cloudwatch_metric_alarm.cluster_volume_bytes_used[0].arn
  comparison_operator = "GreaterThanThreshold"
  threshold           = local.alarms.cluster_volume_bytes_used.threshold
  period              = local.alarms.cluster_volume_bytes_used.period

  metric {
    name      = "VolumeBytesUsed"
    namespace = "AWS/RDS"
    statistic = local.alarms.cluster_volume_bytes_used.statistic
    dimensions = {
      DBClusterIdentifier = aws_rds_cluster.main.cluster_identifier
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "acu_utilization" {
  count = local.is_serverless && lookup(local.alarms, "acu_utilization", null) != null ? 1 : 0

  alarm_name = "${aws_rds_cluster.main.cluster_identifier}-highACUUtilization"
  alarm_description = jsonencode(merge(local.alarm_instance, {
    message = "RDS Aurora ${aws_rds_cluster.main.cluster_identifier}: ACU Utilization has exceeded ${local.alarms.acu_utilization.threshold}%"
  }))

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ACUUtilization"
  namespace           = "AWS/RDS"
  statistic           = local.alarms.acu_utilization.statistic
  period              = local.alarms.acu_utilization.period
  threshold           = local.alarms.acu_utilization.threshold

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.main.cluster_identifier
  }

  actions_enabled = true
  alarm_actions   = [module.alarm_channel.arn]
  ok_actions      = [module.alarm_channel.arn]
}

resource "massdriver_instance_alarm" "acu_utilization" {
  count = length(aws_cloudwatch_metric_alarm.acu_utilization)

  display_name        = "ACU Utilization"
  cloud_resource_id   = aws_cloudwatch_metric_alarm.acu_utilization[0].arn
  comparison_operator = "GreaterThanThreshold"
  threshold           = local.alarms.acu_utilization.threshold
  period              = local.alarms.acu_utilization.period

  metric {
    name      = "ACUUtilization"
    namespace = "AWS/RDS"
    statistic = local.alarms.acu_utilization.statistic
    dimensions = {
      DBClusterIdentifier = aws_rds_cluster.main.cluster_identifier
    }
  }
}

// Keep the existing CloudWatch alarms (and, from 1.0.4, the instance alarms) when leaving the module.
moved {
  from = module.cluster_volume_bytes_used[0].aws_cloudwatch_metric_alarm.alarm
  to   = aws_cloudwatch_metric_alarm.cluster_volume_bytes_used[0]
}

moved {
  from = module.cluster_volume_bytes_used[0].massdriver_instance_alarm.instance_alarm
  to   = massdriver_instance_alarm.cluster_volume_bytes_used[0]
}

moved {
  from = module.acu_utilization[0].aws_cloudwatch_metric_alarm.alarm
  to   = aws_cloudwatch_metric_alarm.acu_utilization[0]
}

moved {
  from = module.acu_utilization[0].massdriver_instance_alarm.instance_alarm
  to   = massdriver_instance_alarm.acu_utilization[0]
}
