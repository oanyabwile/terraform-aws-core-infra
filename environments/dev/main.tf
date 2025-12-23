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
