
output "launch_config_name" {
  description = "The DNS name of the load balancer."
  value       = aws_launch_configuration.sam-code-test.name
}

output "public_subnet_id" {
  description = "The subnet ID of the first public subnet (where the NAT lives)"
  value       = aws_subnet.public[0].id
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = "http://${aws_alb.sam-code-test.dns_name}"
}
