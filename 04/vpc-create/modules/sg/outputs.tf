output "security_group_id" {
  value       = aws_security_group.allow_web.id
  description = "Security group ID"
}
