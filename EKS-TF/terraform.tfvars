# Copy this file to terraform.tfvars and customize for your environment

# Cluster Configuration
cluster_name    = "EKS_MARIO"
aws_region      = "us-east-1"
eks_version     = "1.36"

# Node Group Configuration
node_group_name = "Node-mario"
instance_types  = ["t3.medium"]
desired_size    = 2
max_size        = 4
min_size        = 1
disk_size       = 30

# Security Configuration
ssh_key_name    = "eks-key"

# Environment Configuration
environment     = "Production"
project_name    = "Super Mario EKS Deployment"

# Logging Configuration
enable_logging      = true
log_retention_days  = 14

# VPC Configuration (production baseline — override per env via envs/*.tfvars)
vpc_name             = "previselab-vpc"
vpc_cidr             = "10.30.0.0/16"
public_subnet_cidrs  = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
private_subnet_cidrs = ["10.30.11.0/24", "10.30.12.0/24", "10.30.13.0/24"]
azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
