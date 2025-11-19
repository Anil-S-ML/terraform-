variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "private_subnet_cidr_block" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "public_subnet_cidr_block" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "avail_zone" {
  description = "List of availability zones"
  type        = list(string)
}
