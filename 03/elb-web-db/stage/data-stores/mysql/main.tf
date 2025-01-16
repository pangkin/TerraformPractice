################################
# 작성일: 25.01.16
# 작성자: pangkin
# db 구성
################################

# Provider 설정
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "bucket-ajj-09999"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "myTFLocks-table"
  }
}

provider "aws" {
  region = "us-east-2"
}

# DB instance 설정
resource "aws_db_instance" "my_db" {
  allocated_storage = 10

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  db_name = "myDB"

  username = var.db_user
  password = var.db_password

  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}
