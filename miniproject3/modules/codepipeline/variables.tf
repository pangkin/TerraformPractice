variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS account id"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name"
  type        = string
}

variable "codebuild_name" {
  description = "Codebuild project name"
  type        = string
}

variable "github_repo_name" {
  description = "Github repository name"
  type        = string
}
