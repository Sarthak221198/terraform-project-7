variable "ami_id"{}
variable "instance_type"{}
variable "project_name" {}
variable "public_key"{}
variable "subnet_id"{}
variable "sg_for_jenkins"{}
variable "enable_public_ip_address"{}

output "jenkins_ec2_instance_ip" {
  value = aws_instance.jenkins_ec2_instance_ip.id
}

output "jenkins_ec2_instance_public_key" {
  value = aws_key_pair.jenkins_ec2_instance_public_key.id
}


resource "aws_instance" "jenkins_ec2_instance_ip" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags = {
    Name = "${var.project_name}-ec2"
  }
  key_name                    = "jenkins_demo"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.sg_for_jenkins
  associate_public_ip_address = var.enable_public_ip_address

  user_data = filebase64("Jenkins/jenkins.sh")

  metadata_options {
    http_endpoint = "enabled"  # Enable the IMDSv2 endpoint
    http_tokens   = "required" # Require the use of IMDSv2 tokens
  }
}

resource "aws_key_pair" "jenkins_ec2_instance_public_key" {
  key_name   = "jenkins_demo"
  public_key = var.public_key
}