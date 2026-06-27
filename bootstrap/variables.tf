variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "mario12bucket"
}

variable "aws_region" {
  description = "AWS region for the S3 bucket"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "previse"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "shared"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "Super Mario EKS Deployment"
}
