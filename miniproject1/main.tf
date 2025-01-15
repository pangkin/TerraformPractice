################################
# 작성일 25.01.15
# 작성자: pangkin
# 개발자를 위한 EC2 인스턴스 생성
################################

################################
# 기본 인프라 구성
################################

# 1. VPC 설정
resource "aws_vpc" "my" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

# 2. Internet Gateway 설정
resource "aws_internet_gateway" "my" {
  vpc_id = aws_vpc.my.id

  tags = {
    Name = "my-igw"
  }
}

# 3. Public subnet 설정
resource "aws_subnet" "my_public" {
  vpc_id     = aws_vpc.my.id
  cidr_block = "10.123.0.0/24"

  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "my-public-sn"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# 4. Public Routing 설정
resource "aws_route_table" "my_public" {
  vpc_id = aws_vpc.my.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my.id
  }

  tags = {
    Name = "my-public-rt"
  }
}

# 5. Public Routing Table Association 설정
resource "aws_route_table_association" "my_sn_rt_asso" {
  subnet_id      = aws_subnet.my_public.id
  route_table_id = aws_route_table.my_public.id
}

################################
# EC2 인스턴스 생성
################################

# 1. Public Security Group 설정 -> 전체 포트 허용
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.my.id

  tags = {
    Name = "allow_all"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_all" {
  security_group_id = aws_security_group.allow_all.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.allow_all.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# 2. SSH Key 생성
resource "aws_key_pair" "mykeypair3" {
  key_name   = "mykeypair3"
  public_key = file("${var.identity_file}.pub")
}

# 3. AMI Data Source 설정
data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# 4. EC2 Instance 생성
resource "aws_instance" "my_dev_server" {
  ami           = data.aws_ami.ubuntu_2404.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.mykeypair3.key_name

  subnet_id              = aws_subnet.my_public.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]

  user_data_replace_on_change = true
  user_data = file("userdata.tpl")

  depends_on = [aws_internet_gateway.my]

  tags = {
    Name = "myDevServer"
  }

  provisioner "local-exec" {
    command = templatefile("sshconfig.tpl", { 
      hostname = self.public_ip,
      identityfile = var.identity_file,
      username = "ubuntu"
      })
    interpreter = [ "/bin/bash", "-c" ]
  }
}
