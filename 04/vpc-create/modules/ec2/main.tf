##############################
# 작성일: 25.01.20
# 작성자: pangkin
# EC2 module
##############################


# AMI
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

# Instance 생성
resource "aws_instance" "instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  user_data = file("${path.module}/userdata.sh")

  subnet_id              = var.subnet_id # Required
  vpc_security_group_ids = var.vpc_security_group_ids

  key_name = var.key_name

  tags = {
    Name = var.name
  }
}
