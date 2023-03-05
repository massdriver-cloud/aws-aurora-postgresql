locals {
  writer_data_authentication = {
    username = random_pet.root_username.id
    password = random_password.root_password.result
    hostname = aws_rds_cluster.main.endpoint
    port     = local.postgresql.port
  }

  readers_data_authentication = {
    username = random_pet.root_username.id
    password = random_password.root_password.result
    hostname = aws_rds_cluster.main.reader_endpoint
    port     = local.postgresql.port
  }

  data_infrastructure = {
    arn = aws_rds_cluster.main.arn
  }

  data_security = {
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
  field                = "writer"
  provider_resource_id = aws_rds_cluster.main.arn
  name                 = "PostgreSQL Primary (writer): ${aws_rds_cluster.main.arn}"
  artifact = jsonencode(
    {
      data = {
        infrastructure = local.data_infrastructure
        authentication = local.writer_data_authentication
        security       = local.data_security
      }
      specs = {
        rdbms = local.rdbms_specs
      }
    }
  )
}

resource "massdriver_artifact" "readers" {
  field                = "readers"
  provider_resource_id = aws_rds_cluster.main.arn
  name                 = "PostgreSQL Replicas (reader): ${aws_rds_cluster.main.arn}"
  artifact = jsonencode(
    {
      data = {
        infrastructure = local.data_infrastructure
        authentication = local.readers_data_authentication
        security       = local.data_security
      }
      specs = {
        rdbms = local.rdbms_specs
      }
    }
  )
}
