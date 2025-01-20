##############################
# 작성일: 25.01.20
# 작성자: pangkin
# VPC module
##############################

# VPC 생성
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr

  tags = {
    Name = var.name
  }
}

# Internet gatewat 생성 및 연결
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-igw"
  }
}

# Public subnet 생성
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet
  availability_zone = var.availability_zone

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-subnet"
  }
}

# Public routing table 생성
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.name}-public-rt"
  }
}

# Public routing table에 subnet 연결
resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}
