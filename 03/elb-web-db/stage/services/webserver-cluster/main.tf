################################
# 작성일: 25.01.16
# 작성자: pangkin
# ALB + ASG 구성
################################

# Provider 설정
provider "aws" {
  region = "us-east-2"
}


################################
# 1. Basic infra configuration
################################

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Dafault subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


################################
# 2. ALB + TG(ASG, EC2 x 2)
################################

# 2-1. ASG

# Security Group
resource "aws_security_group" "my_asg" {
  name        = "myASGSG"
  description = "Allow 8080 port inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "myASGSG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "my_asg_allow_web" {
  security_group_id = aws_security_group.my_asg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.server_port
  ip_protocol       = "tcp"
  to_port           = var.server_port
}

resource "aws_vpc_security_group_ingress_rule" "my_asg_allow_ssh" {
  security_group_id = aws_security_group.my_asg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "my_asg_allow_all" {
  security_group_id = aws_security_group.my_asg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Launch Template
resource "aws_launch_template" "my_web" {
  name = "myWEB"

  image_id      = data.aws_ami.ubuntu2404.id
  instance_type = "t2.micro"

  key_name = "mykeypair2"

  vpc_security_group_ids = [aws_security_group.my_asg.id]

  user_data = base64encode(templatefile("user-data.tpl", {
    db_address  = data.terraform_remote_state.my_db.outputs.address,
    db_port     = data.terraform_remote_state.my_db.outputs.port,
    server_port = var.server_port
  }))

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "myWEB"
    }
  }
}

data "terraform_remote_state" "my_db" {
  backend = "s3"

  config = {
    bucket = "bucket-ajj-09999"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"
  }
}

data "aws_ami" "ubuntu2404" {
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

# Auto Scaling Group
resource "aws_autoscaling_group" "my_web" {
  name = "myALB"

  desired_capacity = 2
  min_size         = 2
  max_size         = 10

  health_check_grace_period = 300
  health_check_type         = "ELB"

  force_delete = true

  target_group_arns = [aws_lb_target_group.my_web.arn]
  depends_on        = [aws_lb_target_group.my_web]

  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.my_web.id
    version = aws_launch_template.my_web.latest_version
  }
}

# 2-2. TG + ALB

# Security Group
resource "aws_security_group" "my_alb" {
  name        = "myALBSG"
  description = "Allow web inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "myALBSG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "my_alb_allow_web" {
  security_group_id = aws_security_group.my_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "my_alb_allow_all" {
  security_group_id = aws_security_group.my_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Target Group
resource "aws_lb_target_group" "my_web" {
  name     = "myWebTG"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

# Application Load Balancer
resource "aws_lb" "my_web" {
  name               = "my-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_alb.id]
  subnets            = data.aws_subnets.default.ids
}

# ALB Listener
resource "aws_lb_listener" "my_web" {
  load_balancer_arn = aws_lb.my_web.arn
  port              = "80"
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

# ALB Listener rule
resource "aws_lb_listener_rule" "my_web" {
  listener_arn = aws_lb_listener.my_web.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_web.arn
  }

  condition {
    path_pattern {
      values = ["/index.html"]
    }
  }
}
