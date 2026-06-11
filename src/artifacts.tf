locals {
  writer_authentication = {
    username = aws_rds_cluster.main.master_username
    password = aws_rds_cluster.main.master_password
    hostname = aws_rds_cluster.main.endpoint
    port     = local.postgresql.port
  }

  readers_authentication = {
    username = aws_rds_cluster.main.master_username
    password = aws_rds_cluster.main.master_password
    hostname = aws_rds_cluster.main.reader_endpoint
    port     = local.postgresql.port
  }

  infrastructure = {
    arn = aws_rds_cluster.main.arn
  }

  security = {
    network = {
      postgresql = {
        arn      = aws_security_group.main.arn
        port     = local.postgresql.port
        protocol = local.postgresql.protocol
      }
    }
  }

  rdbms_specs = {
    engine         = "PostgreSQL"
    engine_version = aws_rds_cluster.main.engine_version
    version        = aws_rds_cluster.main.engine_version_actual
  }
}

resource "massdriver_artifact" "writer" {
  field    = "writer"
  name     = "PostgreSQL Primary (writer): ${aws_rds_cluster.main.arn}"
  artifact = jsonencode(
    {
      infrastructure = local.infrastructure
      authentication = local.writer_authentication
      security       = local.security
      specs = {
        rdbms = local.rdbms_specs
      }
    }
  )
}

resource "massdriver_artifact" "readers" {
  field    = "readers"
  name     = "PostgreSQL Replicas (reader): ${aws_rds_cluster.main.arn}"
  artifact = jsonencode(
    {
      infrastructure = local.infrastructure
      authentication = local.readers_authentication
      security       = local.security
      specs = {
        rdbms = local.rdbms_specs
      }
    }
  )
}
