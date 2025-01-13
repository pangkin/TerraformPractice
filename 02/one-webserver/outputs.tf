output "public_ip" {
  value       = aws_instance.myweb.public_ip
  description = "Public IP of EC2 instance"
}
