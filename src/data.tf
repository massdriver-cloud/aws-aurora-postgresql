data "aws_caller_identity" "current" {}

data "aws_kms_alias" "postgresql" {
  name = "alias/${var.md_metadata.name_prefix}-postgresql-encryption"
}
