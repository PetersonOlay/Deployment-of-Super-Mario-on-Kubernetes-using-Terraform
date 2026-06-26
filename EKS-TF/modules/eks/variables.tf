variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_version" {
  description = "EKS Kubernetes version"
  type        = string
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
}

variable "instance_types" {
  description = "EC2 instance types for node group"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "disk_size" {
  description = "Disk size in GiB for worker nodes"
  type        = number
}

variable "ssh_key_name" {
  description = "SSH key pair name for node access"
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

variable "enable_logging" {
  description = "Enable EKS control plane logging"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
}

variable "vpc_id" {
  description = "ID of the VPC in which to deploy the EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets for EKS node group placement"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets for EKS control plane ENI placement"
  type        = list(string)
}
