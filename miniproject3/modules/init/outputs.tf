output "repository_url" {
  value = aws_ecr_repository.ecr_repository.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.ecs_service.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.ecr_repository.repository_url
}

output "ecr_url" {
  value = split("/", aws_ecr_repository.ecr_repository.repository_url)[0]
}

output "alb_url" {
  value = aws_lb.alb.dns_name
}
