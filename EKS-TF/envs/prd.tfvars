# Production environment overrides
# Usage: terraform plan -var-file=envs/prd.tfvars

environment        = "prd"
cluster_name       = "EKS_MARIO"
node_group_name    = "Node-mario"
ssh_key_name       = null  # set to an EC2 key pair name to enable SSH; null uses SSM

# Standard production sizing
instance_types     = ["t3.medium"]
desired_size       = 2
max_size           = 4
min_size           = 1
disk_size          = 30
log_retention_days = 14

# Production VPC
vpc_name             = "previselab-vpc"
vpc_cidr             = "10.30.0.0/16"
public_subnet_cidrs  = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
private_subnet_cidrs = ["10.30.11.0/24", "10.30.12.0/24", "10.30.13.0/24"]
azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
