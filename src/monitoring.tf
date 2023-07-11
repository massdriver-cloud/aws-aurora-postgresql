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
  }
  alarms_map = {
    "AUTOMATED" = local.automated_alarms
    "DISABLED"  = {}
    // "CUSTOM"    = lookup(var.monitoring, "alarms", {})
  }

  // No UI control supported yet.
  //alarms = lookup(local.alarms_map, var.monitoring.mode, {})
  alarms = local.alarms_map["AUTOMATED"]
}

module "alarm_channel" {
  source      = "github.com/massdriver-cloud/terraform-modules//aws/alarm-channel?ref=f3163aa"
  md_metadata = var.md_metadata
}

module "cluster_volume_bytes_used" {
  count = lookup(local.alarms, "cluster_volume_bytes_used", null) == null ? 0 : 1

  source        = "github.com/massdriver-cloud/terraform-modules//aws/cloudwatch-alarm?ref=f3163aa"
  sns_topic_arn = module.alarm_channel.arn
  depends_on = [
    aws_rds_cluster.main
  ]

  md_metadata         = var.md_metadata
  display_name        = "Cluster Volume Bytes Used"
  message             = "RDS Aurora ${aws_rds_cluster.main.cluster_identifier}: Cluster Volume Bytes Used has exceeded ${local._cluster_volume_bytes_max_threshold}% of ${local._cluster_volume_bytes_max_tib}TiB"
  alarm_name          = "${aws_rds_cluster.main.cluster_identifier}-highClusterVolumeBytesUsed"
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
}
