variable "project_name" {
  default = "cicd"
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "vpc_public_subnets" {
  description = "VPC public subnets"
  type        = list(string)
}
