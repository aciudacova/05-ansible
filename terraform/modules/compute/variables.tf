variable "environment" {
  type = string
}

variable "ami_id" {
  description = "The AMI to use for the instances."
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID to launch instances into."
  type        = string
}

variable "lb_sg_id" {
  description = "The security group ID for the load balancer."
  type        = string
}

variable "webserver_sg_id" {
  description = "The security group ID for the web servers."
  type        = string
}

variable "lb_instance_count" {
  description = "Number of load balancer instances to create."
  type        = number
}

variable "web_instance_count" {
  description = "Number of web server instances to create."
  type        = number
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "The name of the AWS key pair to use for the instances."
  type        = string
}