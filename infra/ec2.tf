
# This file defines the EC2 instance and related resources.
data "aws_ami" "amzn_linux_2023_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# # Create a key pair for EC2 instance
# resource "aws_key_pair" "key1" {
#   key_name   = "test"
#   public_key = file("${pathexpand("~/.ssh/test.pub")}")

#   tags = {
#     Name        = "test"
#     environment = "dev"
#   }
# }

resource "aws_key_pair" "key2" {
  key_name   = "test"
  public_key = var.ec2_public_key

  tags = {
    Name        = "test"
    environment = "dev"
  }
}

# Create EC2 instance in public subnet 1
resource "aws_instance" "instance1" {
  ami                    = data.aws_ami.amzn_linux_2023_ami.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.key2.key_name
  monitoring             = true
  user_data_base64       = base64encode(file("${path.module}/templates/user_data.sh"))
  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = 30
    volume_type = "gp3"
    # kms_key_id = var.kms_key_id
  }

  #   cpu_options {
  #     core_count       = 2
  #     threads_per_core = 2
  #   }

  tags = {
    Name        = "tf-example"
    environment = "dev"
  }
}

# Allocate an Elastic IP and associate it with the EC2 instance
resource "aws_eip" "eip1" {
  instance = aws_instance.instance1.id
  domain   = "vpc"
}