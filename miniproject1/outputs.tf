output "EC2_public_ip" {
  value       = aws_instance.my_dev_server.public_ip
  description = "EC2 Public Ip address"
}
