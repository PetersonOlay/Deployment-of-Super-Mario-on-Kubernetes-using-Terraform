module "vpc" {
  source = "./modules/vpc"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  cluster_name         = var.cluster_name
  environment          = var.environment
  project_name         = var.project_name
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  eks_version        = var.eks_version
  node_group_name    = var.node_group_name
  instance_types     = var.instance_types
  desired_size       = var.desired_size
  max_size           = var.max_size
  min_size           = var.min_size
  disk_size          = var.disk_size
  ssh_key_name       = var.ssh_key_name
  environment        = var.environment
  project_name       = var.project_name
  enable_logging     = var.enable_logging
  log_retention_days = var.log_retention_days

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
}
