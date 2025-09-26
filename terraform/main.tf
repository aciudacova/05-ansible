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
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
  backend "local" {}
}

provider "aws" {
  region              = "eu-north-1"
  allowed_account_ids = ["910681227783"]
}

provider "http" {

}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"] # Debian's official account ID for AMIs

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

data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "./shared_network/terraform.tfstate"
  }
}

module "compute" {
  source = "./modules/compute"

  environment        = var.environment
  instance_type      = var.instance_type
  lb_instance_count  = var.lb_instance_count
  web_instance_count = var.web_instance_count

  ami_id   = data.aws_ami.debian.id
  key_name = data.terraform_remote_state.network.outputs.ssh_key_name

  subnet_id       = data.terraform_remote_state.network.outputs.public_subnet_id
  lb_sg_id        = data.terraform_remote_state.network.outputs.loadbalancer_sg_id
  webserver_sg_id = data.terraform_remote_state.network.outputs.webserver_sg_id
}
