# terraform & provider 설정
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

# 0. 기본 인프라 구성
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 1. ASG 생성

# 1) 보안 그룹 생성
resource "aws_security_group" "myASG_sg" {
  name        = "myASG_sg"
  description = "Allow SSH, HTTP inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "myASG_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "myASG_sg_allow_ssh" {
  security_group_id = aws_security_group.myASG_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "myASG_sg_allow_http" {
  security_group_id = aws_security_group.myASG_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.web_port
  ip_protocol       = "tcp"
  to_port           = var.web_port
}

resource "aws_vpc_security_group_egress_rule" "myASG_sg_allow_all_traffic" {
  security_group_id = aws_security_group.myASG_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# 2) 시작 템플릿 생성
resource "aws_launch_template" "myASG_template" {
  name = "myASG_template"

  image_id      = data.aws_ami.al2023.id
  instance_type = "t2.micro"
  key_name = "mykeypair2"

  vpc_security_group_ids = [aws_security_group.myASG_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum install -y httpd mod_ssl
    echo "myWEB" > /var/www/html/index.html
    systemctl enable --now httpd.service
    EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-*-x86_64"]
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

# 3) autoscaling group 생성
resource "aws_autoscaling_group" "myASG" {
  name = "myASG"

  target_group_arns = [aws_lb_target_group.myALB_tg.arn]
  depends_on        = [aws_lb_target_group.myALB_tg]

  vpc_zone_identifier = data.aws_subnets.default.ids

  min_size = var.instance_size.min
  max_size = var.instance_size.max

  launch_template {
    id = aws_launch_template.myASG_template.id
  }
}

# 2. ALB 생성

# 1) 보안 그룹 생성
resource "aws_security_group" "myALB_sg" {
  name        = "myALB_sg"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "myALB_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "myALB_sg_allow_http" {
  security_group_id = aws_security_group.myALB_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.web_port
  ip_protocol       = "tcp"
  to_port           = var.web_port
}

resource "aws_vpc_security_group_egress_rule" "myALB_sg_allow_all_traffic" {
  security_group_id = aws_security_group.myALB_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# 2) LB target group 생성
resource "aws_lb_target_group" "myALB_tg" {
  name     = "myALB-tg"
  port     = var.web_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

# 3) LB 구성
resource "aws_lb" "myALB" {
  name               = "myALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.myALB_sg.id]
  subnets            = data.aws_subnets.default.ids
}

# 4) LB listener 구성
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.myALB.arn
  port              = var.web_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = <<-EOF
        <html lang="ko_kr">
        <head>
          <title>Not found</title>
        </head>
        <body>
          <center>
            <h1>404</h1>
            <p>Page not found</p>
          </center>
        </body>
        </html>
        EOF
      status_code  = "404"
    }
  }
}
# 5) LB listener rule 구성
resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myALB_tg.arn
  }

  condition {
    path_pattern {
      values = ["/index.html"]
    }
  }
}
