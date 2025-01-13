variable "security_group_name" {
  description = "Name of security group"
  type        = string
  default     = "allow_8080"
}

variable "server_port" {
  description = "Port for Security group"
  type        = number
  default     = 8080
}
