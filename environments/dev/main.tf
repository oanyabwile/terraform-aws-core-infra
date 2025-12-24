provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"

  name       = "core-dev"
  cidr_block = "10.0.0.0/16"

  azs = [
    "us-east-2a",
    "us-east-2b"
  ]

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]
}

module "security_groups" {
  source = "../../modules/security-groups"

  name   = "core-dev"
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source = "../../modules/alb"

  name              = "core-dev"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_sg_id
}

module "asg" {
  source = "../../modules/asg"

  name = "core-dev"

  private_subnet_ids = module.vpc.private_subnet_ids
  target_group_arn   = module.alb.target_group_arn
  app_sg_id          = module.security_groups.app_sg_id

  instance_profile_name = "ec2-instance-profile"

  min_size         = 1
  desired_capacity = 2
  max_size         = 3
}

module "rds" {
  source = "../../modules/rds"

  name               = "core-dev"
  db_name            = "appdb"
  db_username        = "appuser"
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id          = module.security_groups.rds_sg_id
}

