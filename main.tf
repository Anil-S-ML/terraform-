provider "aws" {
}


variable vpc_cidr_block{}
variable subnet_cidr_block{}
variable avail_zone{}
variable env_prefix{}
variable my_ip{}
variable instance_type{}
variable my_public_key{}

resource "aws_vpc" "my-app-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "my-app-subnet" {
  vpc_id            = aws_vpc.my-app-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone

  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "my-app-igw"{
    vpc_id = aws_vpc.my-app-vpc.id

    tags ={
        Name = "${var.env_prefix}-igw"
    }
}

resource "aws_default_route_table" "main_route_table"{
    default_route_table_id = aws_vpc.my-app-vpc.default_route_table_id 
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-app-igw.id
    }
    tags = {
        Name : "${var.env_prefix}-main-rtb"

}
}
resource "aws_default_security_group" "default-sg"{
    vpc_id = aws_vpc.my-app-vpc.id

    ingress{
        from_port =22
        to_port = 22
        protocol ="TCP"
        cidr_blocks=[var.my_ip]
    }
    ingress{
        from_port =8080
        to_port = 8080
        protocol ="TCP"
        cidr_blocks=["0.0.0.0/0"]
    }
    egress{
        from_port =0
        to_port = 0
        protocol ="-1"
        cidr_blocks=["0.0.0.0/0"]
        prefix_list_ids=[]
    }
     tags = {
        Name : "${var.env_prefix}-default-sg"
}
}

data "aws_ami" "latest_amazon_linux_image"{
    most_recent = true 
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["Deep Learning Proprietary Nvidia Driver AMI GPU TensorFlow 2.16 (Amazon Linux 2) 20240607"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}
output "aws_ami_id"{
    value =  data.aws_ami.latest_amazon_linux_image.id
}
output "ec2_public_ip"{
     value = aws_instance.my-app-server.public_ip 
}

resource "aws_key_pair" "ssh-key"{
    key_name = "server-key"
    public_key = var.my_public_key
}

resource "aws_instance" "my-app-server"{
    ami = data.aws_ami.latest_amazon_linux_image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.my-app-subnet.id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true
     key_name = aws_key_pair.ssh-key.key_name

     user_data = file("entry-script.sh")
    user_data_replace_on_change = true 

     tags={
         Name : "${var.env_prefix}-server"
     }
}