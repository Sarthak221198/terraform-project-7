variable "lb_name" {}
variable "sg_enable_ssh_https"{}
variable "cidr_public_subnet"{}
variable "project_name" {}
variable "lb_listner_port" {}
variable "lb_listner_protocol" {}
variable "lb_listner_default_action" {}
# variable "lb_https_listner_port" {}
# variable "lb_https_listner_protocol" {}

resource "aws_lb" "dev_proj_1_lb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_enable_ssh_https]
  subnets            = var.cidr_public_subnet # Replace with your subnet IDs

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-ec2"
  }
}

# http listner on port 80
resource "aws_lb_listener" "dev_proj_1_lb_http_listner" {
  load_balancer_arn = aws_lb.dev_proj_1_lb.arn
  port              = var.lb_listner_port
  protocol          = var.lb_listner_protocol

  default_action {
    type             = var.lb_listner_default_action
    target_group_arn = aws_lb_target_group.dev_proj_1_lb_target_group.arn
  }
}

# # https listner on port 443
# resource "aws_lb_listener" "dev_proj_1_lb_https_listner" {
#   load_balancer_arn = aws_lb.dev_proj_1_lb.arn
#   port              = var.lb_https_listner_port
#   protocol          = var.lb_https_listner_protocol
#   ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2019-08"

#   default_action {
#     type             = var.lb_listner_default_action
#     target_group_arn = aws_lb_target_group.dev_proj_1_lb_target_group.arn
#   }
# }

variable "lb_target_group_name" {}
variable "lb_target_group_port" {}
variable "lb_target_group_protocol" {}
variable "vpc_cidr" {}
variable "jenkins_ec2_instance_ip" {}

output "dev_proj_1_lb_target_group_arn" {
  value = aws_lb_target_group.dev_proj_1_lb_target_group.arn
}

resource "aws_lb_target_group" "dev_proj_1_lb_target_group" {
  name     = var.lb_target_group_name
  port     = var.lb_target_group_port
  protocol = var.lb_target_group_protocol
  vpc_id   = var.vpc_cidr
  health_check {
    path = "/login"
    port = 8080
    healthy_threshold = 6
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"  # has to be HTTP 200 or fails
  }
}

resource "aws_lb_target_group_attachment" "dev_proj_1_lb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.dev_proj_1_lb_target_group.arn
  target_id        = var.jenkins_ec2_instance_ip
  port             = 8080
}
