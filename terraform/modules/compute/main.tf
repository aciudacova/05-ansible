resource "aws_instance" "loadbalancer" {
  count                  = var.lb_instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.lb_sg_id]
  
  tags = {
    Name = "${var.environment}-lb-${count.index + 1}"
    Role = "loadbalancer"
    Env  = var.environment
  }
}

resource "aws_instance" "web_server" {
  count                  = var.web_instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.webserver_sg_id]
  
  tags = {
    Name = "${var.environment}-web-${count.index + 1}"
    Role = "webserver"
    Env  = var.environment
  }
}