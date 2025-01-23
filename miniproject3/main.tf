# VPC 생성
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "cicd-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets = ["10.0.0.0/24", "10.0.1.0/24"]

  map_public_ip_on_launch = true
}

module "init" {
  source = "./modules/init"

  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  vpc_public_subnets = module.vpc.public_subnets
}

module "codebuild" {
  source = "./modules/codebuild"

  aws_region   = var.aws_region
  account_id   = var.account_id
  project_name = var.project_name
}

module "codepipeline" {
  source = "./modules/codepipeline"

  aws_region       = var.aws_region
  account_id       = var.account_id
  project_name     = var.project_name
  ecs_cluster_name = module.init.ecs_cluster_name
  ecs_service_name = module.init.ecs_service_name
  codebuild_name   = module.codebuild.codebuild_name
  github_repo_name = var.github_repo_name
}
