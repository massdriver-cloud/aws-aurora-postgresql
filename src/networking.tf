resource "aws_db_subnet_group" "main" {
  name        = var.md_metadata.name_prefix
  description = "Aurora PostgreSQL ${var.md_metadata.name_prefix}"
  subnet_ids  = local.subnet_ids[var.networking.subnet_type]
}

resource "aws_security_group" "main" {
  vpc_id      = local.vpc_id
  name_prefix = "${var.md_metadata.name_prefix}-"
  description = "Control traffic to/from Aurora PostgreSQL ${var.md_metadata.name_prefix}"
  lifecycle {
    create_before_destroy = true
  }
}

# Note: this rule here is to support ingress from the VPC until we add in security group support for applications in AWS
resource "aws_security_group_rule" "vpc_ingress" {
  count       = 1
  description = "From allowed CIDRs"
  type        = "ingress"
  from_port   = local.postgresql.port
  to_port     = local.postgresql.port
  protocol    = local.postgresql.protocol
  cidr_blocks = [var.vpc.data.infrastructure.cidr]

  security_group_id = aws_security_group.main.id
}
