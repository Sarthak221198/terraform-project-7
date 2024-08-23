variable "vpc_cidr" {}
variable "project_name" {}
variable "cidr_public_subnet" {}
variable "eu_availability_zone" {}
variable "cidr_private_subnet" {}

output "cidr_public_subnet" {
  value = aws_subnet.pubsub1.*.id
}

output "cidr_private_subnet" {
  value = aws_subnet.prisub1.*.id
}

output "vpc_cidr" {
  value = aws_vpc.my_vpc.id
}

#setup your vpc
resource "aws_vpc" "my_vpc" {
  cidr_block       =  var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

#setup your public subnet
resource "aws_subnet" "pubsub1" {
  count = length(var.cidr_public_subnet) 
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = element(var.cidr_public_subnet, count.index)
  availability_zone = element(var.eu_availability_zone, count.index)

  tags = {
    Name = "${var.project_name}-public_subnet"
  }
}

#setup your private subnet
resource "aws_subnet" "prisub1" {
  count = length(var.cidr_private_subnet) 
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = element(var.cidr_private_subnet, count.index)
  availability_zone = element(var.eu_availability_zone, count.index)

  tags = {
    Name = "${var.project_name}-private_subnet"
  }
}

#setup your igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

#setup your public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public_rt"
  }
}

#setup your public route table assocation
resource "aws_route_table_association" "public_rta" {
  count = length(aws_subnet.pubsub1)  
  subnet_id      = aws_subnet.pubsub1[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

#setup your private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.project_name}-private_rt"
  }
}

#setup your private route table assocation
resource "aws_route_table_association" "private_rta" {
  count = length(aws_subnet.prisub1)  
  subnet_id      = aws_subnet.prisub1[count.index].id
  route_table_id = aws_route_table.private_rt.id
}