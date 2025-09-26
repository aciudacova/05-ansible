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
}

provider "http" {}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

module "networking" {
  source = "../modules/networking"

  environment = "shared"
  allowed_ips = ["195.22.241.18/32", "${chomp(data.http.myip.response_body)}/32"]
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = "shared-main-key-pair"
  public_key = tls_private_key.main.public_key_openssh
}
