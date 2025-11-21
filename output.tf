output "aws_ami_id" {
  value = data.aws_ami.latest_amazon_linux_image.id
}

output "ec2_public_ip_1" {
  value = aws_instance.my_app_server_one.public_ip
}
output "ec2_public_ip_2" {
  value = aws_instance.my_app_server_two.public_ip
}

output "ec2_public_ip_3" {
  value = aws_instance.my_app_server_three.public_ip
}

