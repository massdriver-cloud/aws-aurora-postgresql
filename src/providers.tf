terraform {
  required_version = ">= 1.0"
  required_providers {
    massdriver = {
      source  = "massdriver-cloud/massdriver"
      version = "~> 1.4, >= 1.4.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.vpc.specs.aws.region
  assume_role {
    role_arn    = var.aws_authentication.arn
    external_id = var.aws_authentication.external_id
  }
  default_tags {
    tags = var.md_metadata.default_tags
  }
}
