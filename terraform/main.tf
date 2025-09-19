terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.13"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region              = "eu-north-1"
  allowed_account_ids = ["910681227783"]
  default_tags {
    tags = local.tags
  }
}

provider "http" {
}

locals {
  tags = {
    owner   = "aciudacova"
    purpose = "ansible"
  }
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "allow_ssh_http"
  vpc_id      = aws_vpc.this.id
  ingress {
    description = "allow http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["195.22.241.18/32", "${chomp(data.http.myip.response_body)}/32"]
  }
  ingress {
    description = "allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["195.22.241.18/32", "${chomp(data.http.myip.response_body)}/32"]
  }
  ingress {
    description = "allow https"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["195.22.241.18/32", "${chomp(data.http.myip.response_body)}/32"]
  }
  ingress {
    description = "allow HAProxy Stats from PC IP"
    protocol    = "tcp"
    from_port   = 8404
    to_port     = 8404
    cidr_blocks = ["195.22.241.18/32", "${chomp(data.http.myip.response_body)}/32"]
  }
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

# resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
#   security_group_id = aws_security_group.allow_ssh_http.id
#   description       = "allow ssh"
#   ip_protocol       = "tcp"
#   from_port         = 22
#   to_port           = 22
#   cidr_ipv4         = "${chomp(data.http.myip.response_body)}/32"
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_http" {
#   security_group_id = aws_security_group.allow_ssh_http.id
#   description       = "allow http"
#   ip_protocol       = "tcp"
#   from_port         = 80
#   to_port           = 80
#   cidr_ipv4         = "${chomp(data.http.myip.response_body)}/32"
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_https" {
#   security_group_id = aws_security_group.allow_ssh_http.id
#   description       = "allow https"
#   ip_protocol       = "tcp"
#   from_port         = 443
#   to_port           = 443
#   cidr_ipv4         = "${chomp(data.http.myip.response_body)}/32"
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_haproxy_stats" {
#   security_group_id = aws_security_group.allow_ssh_http.id
#   description       = "allow HAProxy Stats from PC IP"
#   ip_protocol       = "tcp"
#   from_port         = 8404
#   to_port           = 8404
#   cidr_ipv4         = "${chomp(data.http.myip.response_body)}/32"
# }

resource "aws_vpc_security_group_ingress_rule" "allow_self" {
  security_group_id            = aws_security_group.allow_ssh_http.id
  description                  = "allow members of this group to talk to each other"
  ip_protocol                  = "-1" # allow all protocols
  referenced_security_group_id = aws_security_group.allow_ssh_http.id
}

resource "aws_vpc_security_group_egress_rule" "allow_ipv4" {
  security_group_id = aws_security_group.allow_ssh_http.id
  description       = "allow all ipv4"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allow_ipv6" {
  security_group_id = aws_security_group.allow_ssh_http.id
  description       = "allow all ipv6"
  ip_protocol       = "-1"
  cidr_ipv6         = "::/0"
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "MyCLIKeyPair"
  public_key = tls_private_key.example.public_key_openssh
}

data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app_server" {
  count         = var.instance_count
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.generated_key.key_name

  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
}

output "private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}

output "associated_key_name" {
  description = "Name of the generated key"
  value       = aws_key_pair.generated_key.key_name
}

output "ec2_public_ip" {
  description = "Public IP addresses of the EC2 instances."
  value       = aws_instance.app_server[*].public_ip
}

output "ec2_private_ip" {
  description = "Private IP addresses of the EC2 instances."
  value       = aws_instance.app_server[*].private_ip
}
