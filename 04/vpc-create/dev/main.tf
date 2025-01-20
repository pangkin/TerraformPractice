module "vpc" {
  source = "../modules/vpc"

  availability_zone = "ap-northeast-2a"
}

module "sg" {
  source = "../modules/sg"

  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source = "../modules/ec2"

  subnet_id              = module.vpc.subnet_id
  vpc_security_group_ids = [module.sg.security_group_id]
  key_name               = "mykeypair"
}
