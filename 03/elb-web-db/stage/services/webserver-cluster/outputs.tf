output "alb_dns_name" {
  value       = "http://${aws_lb.my_web.dns_name}/index.html"
  description = "DNS name of ALB"
}
