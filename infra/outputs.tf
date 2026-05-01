output "internet_gateway_name" {
  value = aws_internet_gateway.gw.tags.Name
}

output "internet_gateway_id" {
  value = aws_internet_gateway.gw.id
}

output "public_subnet_1_name" {
  value = aws_subnet.public_subnet_1.tags.Name
}

output "public_subnet_1_id" {
  value = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_name" {
  value = aws_subnet.public_subnet_2.tags.Name
}

output "public_subnet_2_id" {
  value = aws_subnet.public_subnet_2.id
}

output "ec2_public_ip" {
  value = aws_eip.eip1.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.main_instance.endpoint
}

output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "rds_port" {
  value = aws_db_instance.main_instance.port
}



