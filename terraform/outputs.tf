output "ssh_private_key" {
  description = "The private key for the single shared SSH key. Save this to a file."
  value       = data.terraform_remote_state.network.outputs.ssh_private_key_pem
  sensitive   = true
}

output "load_balancer_ips" {
  description = "Public and Private IP addresses of the load balancer instances."
  value = [
    for instance in module.compute.loadbalancer_instances : [instance.public_ip, instance.private_ip]
  ]
}

output "web_server_ips" {
  description = "Public and Private IP addresses of the web server instances."
  value = [
    for instance in module.compute.web_server_instances : [instance.public_ip, instance.private_ip]
  ]
}
