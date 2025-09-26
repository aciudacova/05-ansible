variable "environment" {
  description = "The name of the environment (dev, stg, prod)."
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "web_instance_count" {
  description = "Number of web server instances."
  type        = number
}

variable "lb_instance_count" {
  description = "Number of load balancer instances."
  type        = number
  default     = 1
}