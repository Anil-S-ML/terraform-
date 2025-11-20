provider "aws" {
  region = "ap-south-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}
variable "my_public_key" {}
variable "ssh_private_key"{}

resource "aws_vpc" "my_app_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "my_app_subnet" {
  vpc_id            = aws_vpc.my_app_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "my_app_igw" {
  vpc_id = aws_vpc.my_app_vpc.id

  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_app_igw.id
  }

  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}

resource "aws_route_table_association" "my_rtb_association" {
  subnet_id      = aws_subnet.my_app_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "my_sg" {
  name   = "${var.env_prefix}-sg"
  vpc_id = aws_vpc.my_app_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest_amazon_linux_image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Deep Learning Proprietary Nvidia Driver AMI GPU TensorFlow 2.16 (Amazon Linux 2) 20240607"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "server-key-2"
  public_key = file("/home/anil_kumar/.ssh/id_ed25519.pub")
}

resource "aws_instance" "my_app_server" {
  ami                         = data.aws_ami.latest_amazon_linux_image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.my_app_subnet.id
  vpc_security_group_ids      = [aws_security_group.my_sg.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "${var.env_prefix}-server"
  }
provisioner "local-exec" {
    working_dir = "/home/anil_kumar/ansible-project"
    command = <<EOT
      sleep 60
      ansible-playbook \
        --inventory '${self.public_ip},' \
        --private-key '/home/anil_kumar/.ssh/id_ed25519' \
        --user ec2-user \
        -e ansible_python_interpreter=/usr/bin/python3 \
        deploy-docker-new.yaml
    EOT
  }
}

output "aws_ami_id" {
  value = data.aws_ami.latest_amazon_linux_image.id
}

output "ec2_public_ip" {
  value = aws_instance.my_app_server.public_ip
}
