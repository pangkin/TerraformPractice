output "ecr_repository_url" {
  value = module.init.ecr_repository_url
}

output "ecr_url" {
  value = module.init.ecr_url
}

output "alb_url" {
  value = "http://${module.init.alb_url}"
}
