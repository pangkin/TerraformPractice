provider "aws" {
  region = "us-east-2"
}

# Get Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# Create security group to allow SSH inbound
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic and all outbound traffic"

  tags = {
    Name = "allow_ssh"
  }
}

# Create ingress rule for security group to allow SSH inbound
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Create egress rule for security group to allow all outbount traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Create AWS EC2 instance
resource "aws_instance" "myEC2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "mykeypair2"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "myEC2-test"
  }
}

output "amd_id" {
  value       = aws_instance.myEC2.ami
  description = "Ubuntu 24.04 LTS AMI ID"
}

output "vpc_id" {
  value       = aws_security_group.allow_ssh.vpc_id
  description = "VPC ID"
}
