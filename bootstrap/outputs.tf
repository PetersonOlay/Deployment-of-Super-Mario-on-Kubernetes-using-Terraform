output "bucket_name" {
  description = "Name of the Terraform state S3 bucket"
  value       = aws_s3_bucket.terraform_state.id
}

output "bucket_arn" {
  description = "ARN of the Terraform state S3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "terraform_s3_backend_policy_arn" {
  description = "ARN of the IAM policy — attach this to the previsetech IAM user/role"
  value       = aws_iam_policy.terraform_s3_backend.arn
}

output "caller_identity" {
  description = "Current AWS identity running the bootstrap"
  value       = data.aws_caller_identity.current.arn
}

output "next_step" {
  description = "What to do after bootstrap apply"
  value       = "Attach policy '${aws_iam_policy.terraform_s3_backend.arn}' to your IAM user/role, then run: cd ../EKS-TF && terraform init"
}
