variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "name" {
  description = "Name of EC2 instance"
  type        = string
  default     = "myEC2"
}

variable "subnet_id" {
  description = "Subnet id to launch in"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to associate with"
  type        = list(string)
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance"
  type        = string
}
