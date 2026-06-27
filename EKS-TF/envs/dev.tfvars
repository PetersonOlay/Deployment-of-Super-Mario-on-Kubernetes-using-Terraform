# Development environment overrides
# Usage: terraform plan -var-file=envs/dev.tfvars

environment        = "dev"
cluster_name       = "EKS_MARIO_DEV"
node_group_name    = "Node-mario-dev"
ssh_key_name       = null  # set to an EC2 key pair name to enable SSH; null uses SSM

# Small sizing for cost control
instance_types     = ["t3.small"]
desired_size       = 1
max_size           = 2
min_size           = 1
disk_size          = 20
log_retention_days = 7

# Dev VPC — isolated CIDR space
vpc_name             = "previselab-vpc-dev"
vpc_cidr             = "10.10.0.0/16"
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
