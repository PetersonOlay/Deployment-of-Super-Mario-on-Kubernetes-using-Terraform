terraform {
  backend "s3" {
    bucket       = "mario-12-bucket-tf-state-shared"
    key          = "eks/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
