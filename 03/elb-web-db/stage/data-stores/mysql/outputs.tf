output "address" {
  description = "MySQL DB address"
  value       = aws_db_instance.my_db.address
}

output "port" {
  description = "MySQL DB port"
  value       = aws_db_instance.my_db.port
}