output "loadbalancer_instances" {
  description = "The full list of load balancer EC2 instance objects."
  value       = aws_instance.loadbalancer
}

output "web_server_instances" {
  description = "The full list of web server EC2 instance objects."
  value       = aws_instance.web_server
}
