provider "aws"{
    region = "ap-south-2"
}

# variable vpc_cidr_block{}
# variable private_subnet_cidr_block{}
# variable public_subnet_cidr_block{}

data "aws_availability_zones" "azs" {
  state = "available"
}

module "myapp-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"

  name = "myapp-vpc"
  cidr = var.vpc_cidr_block

  azs = var.avail_zone

  private_subnets = var.private_subnet_cidr_block
  public_subnets  = var.public_subnet_cidr_block


  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/myapp-vpc-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/myapp-vpc-cluster" = "shared"
    "kubernetes.io/role/elb"                  = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/myapp-vpc-cluster" = "shared"
    "kubernetes.io/role/internal-elb"         = 1
  }
}
