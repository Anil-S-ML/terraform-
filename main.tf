provider "aws" {
  region     = "us-east-1"
}

variable "subnet_cidr_block"{
    
    description = "subnet_cidr_block"
}

resource "aws_vpc" "development-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name     = "development"
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id            = aws_vpc.development-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-dev-1"
  }
}

data "aws_vpc" "existing_vpc" {
  default = true
}

resource "aws_subnet" "dev-subnet-2" {
  vpc_id            = aws_vpc.development-vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-dev-2"
  }
}

output "dev-vpc-id"{
    value = aws_vpc.development-vpc.id
}

output "dev-subnet-id"{
    value = aws_subnet.dev-subnet-1.id
}
