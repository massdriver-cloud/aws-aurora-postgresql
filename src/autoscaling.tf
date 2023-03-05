resource "aws_appautoscaling_target" "main" {

  # TODO: 0-15 val
  max_capacity       = 3 # var.autoscaling_max_capacity
  min_capacity       = 1 # var.autoscaling_min_capacity
  resource_id        = "cluster:${aws_rds_cluster.main.cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

resource "aws_appautoscaling_policy" "main" {
  # TODO:
  name               = var.md_metadata.name_prefix
  policy_type        = "TargetTrackingScaling"
  resource_id        = "cluster:${aws_rds_cluster.main.cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      # TODO:
      predefined_metric_type = "RDSReaderAverageDatabaseConnections"
      # predefined_metric_type = var.predefined_metric_type
    }

    # TODO: seconds, default 300
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    #scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    #scale_out_cooldown = var.autoscaling_scale_out_cooldown

    target_value = 100

    # TODO:
    # target_value       = var.predefined_metric_type == "RDSReaderAverageCPUUtilization" ?
    #   var.autoscaling_target_cpu :
    #   var.autoscaling_target_connections
  }

  depends_on = [
    aws_appautoscaling_target.main
  ]
}
