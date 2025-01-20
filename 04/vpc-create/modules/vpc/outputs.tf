output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "Id of VPC"
}

output "subnet_id" {
  value       = aws_subnet.public_subnet.id
  description = "Id of public subnet"
}
