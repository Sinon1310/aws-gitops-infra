terraform {
  backend "s3" {
    bucket         = "sinon-terraform-state-2025"
    key            = "aws-gitops-infra/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}