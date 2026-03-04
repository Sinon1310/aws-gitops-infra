# VPC
module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
}

# EC2
module "ec2" {
  source            = "./modules/ec2"
  project_name      = var.project_name
  environment       = var.environment
  subnet_id         = module.vpc.public_subnet_id
  vpc_id            = module.vpc.vpc_id
  security_group_id = module.vpc.security_group_id
}