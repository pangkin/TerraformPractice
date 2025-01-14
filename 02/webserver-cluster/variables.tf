variable "region" {
  default     = "us-east-2"
  description = "Default region for AWS"
  type        = string
}

variable "web_port" {
  default     = 80
  description = "Port for web"
  type        = number
}

variable "instance_size" {
  default = {
    min = 2
    max = 10
  }
  type = object({
    min = number
    max = number
  })
}