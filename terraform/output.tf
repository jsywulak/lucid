#output "lb_dns_name" {
#  description = "The DNS name of the load balancer."
#  value       = concat(aws_alb.sam-code-test.dns_name, [""])[0]
#}