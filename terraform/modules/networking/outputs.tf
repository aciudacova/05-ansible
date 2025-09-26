output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "loadbalancer_sg_id" {
  value = aws_security_group.loadbalancer_sg.id
}

output "webserver_sg_id" {
  value = aws_security_group.webserver_sg.id
}