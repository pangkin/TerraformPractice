output "instance_id" {
  value       = aws_instance.instance.id
  description = "Id of EC2 instance"
}

output "public_ip" {
  value       = aws_instance.instance.public_ip
  description = "public ip of EC2 instance"
}
