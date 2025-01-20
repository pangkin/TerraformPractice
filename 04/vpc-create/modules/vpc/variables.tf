variable "cidr" {
  description = "Cidr block of VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "name" {
  description = "Name of VPC"
  type        = string
  default     = "myVPC"
}

variable "availability_zone" {
  description = "AZ for the subnet"
  type        = string
}

variable "public_subnet" {
  description = "Cidr block of public subnet"
  type        = string
  default     = "10.0.1.0/24"
}
