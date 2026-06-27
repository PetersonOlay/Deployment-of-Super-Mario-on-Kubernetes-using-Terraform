output "vpc_id" {
  description = "ID of the previselab-vpc"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets (EKS nodes)"
  value       = module.vpc.private_subnet_ids
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "The Kubernetes cluster certificate authority data"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_iam_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "node_group_iam_role_arn" {
  description = "The ARN of the IAM role for the EKS node group"
  value       = module.eks.node_group_iam_role_arn
}

output "node_group_name" {
  description = "The name of the EKS node group"
  value       = module.eks.node_group_name
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = module.eks.cloudwatch_log_group_name
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider"
  value       = module.eks.oidc_provider_arn
}

output "lb_controller_policy_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM policy"
  value       = module.eks.lb_controller_policy_arn
}

output "configure_kubectl" {
  description = "Command to configure kubectl to connect to the cluster"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}

output "deployment_commands" {
  description = "Commands to deploy the Super Mario application"
  value = [
    "kubectl apply -f k8s/deployment.yaml",
    "kubectl apply -f k8s/service.yaml",
    "kubectl apply -f k8s/horizontal-pod-autoscaler.yaml",
    "kubectl apply -f k8s/network-policy.yaml",
    "# Optional (requires Prometheus Operator): kubectl apply -f k8s/service-monitor.yaml"
  ]
}

output "access_command" {
  description = "Command to get the LoadBalancer URL"
  value       = "kubectl get services mario-service"
}
