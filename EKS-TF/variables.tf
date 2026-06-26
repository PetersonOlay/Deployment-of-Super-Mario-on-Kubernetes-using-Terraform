variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "EKS_CLOUD"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1"
}

variable "eks_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.36"
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
  default     = "Node-cloud"
}

variable "instance_types" {
  description = "EC2 instance types for node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "disk_size" {
  description = "Disk size in GiB for worker nodes"
  type        = number
  default     = 30
}

variable "ssh_key_name" {
  description = "SSH key pair name for node access"
  type        = string
  default     = "eks-key"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "Production"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "Super Mario EKS Deployment"
}

variable "enable_logging" {
  description = "Enable EKS control plane logging"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "previselab-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.30.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets, one per AZ"
  type        = list(string)
  default     = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets, one per AZ"
  type        = list(string)
  default     = ["10.30.11.0/24", "10.30.12.0/24", "10.30.13.0/24"]
}

variable "azs" {
  description = "List of availability zones to deploy subnets into"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
