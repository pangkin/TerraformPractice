output "lb_url" {
  value       = "http://${aws_lb.myALB.dns_name}/index.html"
  description = "DNS name of load balancer"
}