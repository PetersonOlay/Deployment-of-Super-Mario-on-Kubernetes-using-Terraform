# Staging environment overrides
# Usage: terraform plan -var-file=envs/stg.tfvars

environment        = "stg"
cluster_name       = "EKS_MARIO_STG"
node_group_name    = "Node-mario-stg"
ssh_key_name       = "eks-key-stg"

# Medium sizing — mirrors production topology at reduced scale
instance_types     = ["t3.medium"]
desired_size       = 2
max_size           = 3
min_size           = 1
disk_size          = 30
log_retention_days = 14

# Staging VPC — isolated CIDR space
vpc_name             = "previselab-vpc-stg"
vpc_cidr             = "10.20.0.0/16"
public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
private_subnet_cidrs = ["10.20.11.0/24", "10.20.12.0/24", "10.20.13.0/24"]
azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
