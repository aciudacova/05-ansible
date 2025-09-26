output "vpc_id" {
  description = "The ID of the shared VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_id" {
  description = "The ID of the shared public subnet."
  value       = module.networking.public_subnet_id
}

output "loadbalancer_sg_id" {
  description = "The ID of the shared loadbalancer security group."
  value       = module.networking.loadbalancer_sg_id
}

output "webserver_sg_id" {
  description = "The ID of the shared webserver security group."
  value       = module.networking.webserver_sg_id
}

output "ssh_key_name" {
  description = "The name of the shared AWS key pair."
  value       = aws_key_pair.main.key_name
}

output "ssh_private_key_pem" {
  description = "The private key material for the shared key. Save this to a file."
  value       = tls_private_key.main.private_key_pem
  sensitive   = true
}
