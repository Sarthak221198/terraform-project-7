module "networking" {
  source               = "./networking"
  vpc_cidr             = var.vpc_cidr
  project_name         = var.project_name
  cidr_private_subnet  = var.cidr_private_subnet
  cidr_public_subnet   = var.cidr_public_subnet
  eu_availability_zone = var.eu_availability_zone

}

module "security_group" {
    source = "./security_group"
    ec2_sg_name = "Enable the Port 22(SSH) & Port 80(http)"
    ec2_jenkins_sg_name = "Enable the Port 8080 for jenkins"
    vpc_cidr = module.networking.vpc_cidr
    cidr_public_subnet = tolist(module.networking.cidr_public_subnet)

  
}

module "Jenkins" {
  source                    = "./Jenkins"
  project_name              = var.project_name
  ami_id                    = var.ami_id
  instance_type             = "t2.medium"
  public_key                = var.public_key
  subnet_id                 = tolist(module.networking.cidr_public_subnet)[0]
  sg_for_jenkins            = [module.security_group.ec2_sg_ssh_http, module.security_group.ec2_jenkins_port_8080]
  enable_public_ip_address  = true
}


module "load_balancer" {
  source                    = "./load_balancer"
  lb_target_group_name     = "jenkins-lb-target-group"
  lb_target_group_port     = 8080
  lb_target_group_protocol = "HTTP"
  vpc_cidr = module.networking.vpc_cidr
  jenkins_ec2_instance_ip = module.Jenkins.jenkins_ec2_instance_ip
  project_name = var.project_name
  lb_name = "jenkins-lb"
  sg_enable_ssh_https = module.security_group.ec2_sg_ssh_http
  cidr_public_subnet = module.networking.cidr_public_subnet
  lb_listner_port = 80
  lb_listner_protocol = "HTTP"
  lb_listner_default_action = "forward"
#   lb_https_listner_port = 443
#   lb_https_listner_protocol = "HTTPS"
}