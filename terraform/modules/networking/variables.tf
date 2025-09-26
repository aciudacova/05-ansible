variable "environment" {
  description = "The name of the environment (e.g., dev, stg, prod)."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "allowed_ips" {
  description = "A list of CIDR blocks to allow for SSH, HTTP, and HTTPS."
  type        = list(string)
}