// Auto-generated variable declarations from massdriver.yaml
variable "availability" {
  type = object({
    autoscaling_mode   = string
    min_replicas       = number
    max_replicas       = optional(number)
    scale_in_cooldown  = optional(number)
    scale_out_cooldown = optional(number)
    target_value       = optional(number)
  })
}
variable "aws_authentication" {
  type = object({
    data = object({
      arn         = string
      external_id = optional(string)
    })
    specs = object({
      aws = optional(object({
        region = optional(string)
      }))
    })
  })
}
variable "backup" {
  type = object({
    retention_period    = number
    skip_final_snapshot = bool
  })
}
variable "database" {
  type = object({
    ca_cert_identifier  = string
    deletion_protection = bool
    source_snapshot     = optional(string)
    version             = string
    instance_class      = string
  })
}
variable "md_metadata" {
  type = object({
    default_tags = object({
      managed-by  = string
      md-manifest = string
      md-package  = string
      md-project  = string
      md-target   = string
    })
    deployment = object({
      id = string
    })
    name_prefix = string
    observability = object({
      alarm_webhook_url = string
    })
    package = object({
      created_at             = string
      deployment_enqueued_at = string
      previous_status        = string
      updated_at             = string
    })
    target = object({
      contact_email = string
    })
  })
}
variable "networking" {
  type = object({
    subnet_type = optional(string)
  })
}
variable "observability" {
  type = object({
    enable_cloudwatch_logs_export         = bool
    enhanced_monitoring_interval          = number
    performance_insights_retention_period = number
  })
}
variable "vpc" {
  type = object({
    data = object({
      infrastructure = object({
        arn  = string
        cidr = string
        internal_subnets = list(object({
          arn = string
        }))
        private_subnets = list(object({
          arn = string
        }))
        public_subnets = list(object({
          arn = string
        }))
      })
    })
    specs = optional(object({
      aws = optional(object({
        region = optional(string)
      }))
    }))
  })
}
