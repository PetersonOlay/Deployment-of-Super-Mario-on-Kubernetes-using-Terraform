terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

provider "aws" {
  region                   = var.aws_region
  profile                  = "previsetech"
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
    }
  }
}
