variable "vpc_name" {
  description = "Name tag for the VPC resource"
  type        = string
  default     = "previselab-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zone names to deploy subnets into"
  type        = list(string)
}

variable "cluster_name" {
  description = "EKS cluster name, used for Kubernetes subnet discovery tags"
  type        = string
}

variable "environment" {
  description = "Environment label for tagging"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}
