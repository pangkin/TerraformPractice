output "ec2_public_ip" {
  description = "EC2 public ip"
  value       = module.ec2.public_ip
}