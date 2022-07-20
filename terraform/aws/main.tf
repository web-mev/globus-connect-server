terraform {
  required_version = "~> 1.0.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.22.0"
    }
  }
}

provider "aws" {
}

resource "aws_vpc" "myvpc" {
  cidr_block                       = "192.168.255.0/24"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
}


resource "aws_internet_gateway" "public_gateway" {
  vpc_id = aws_vpc.myvpc.id
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_gateway.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.public_gateway.id
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                          = aws_vpc.myvpc.id
  availability_zone               = var.availability_zone
  cidr_block                      = cidrsubnet(aws_vpc.myvpc.cidr_block, 4, 15)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.myvpc.ipv6_cidr_block, 8, 10)
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true
}


resource "aws_route_table_association" "public_rt" {
  route_table_id                     = aws_route_table.public_route_table.id
  subnet_id                          = aws_subnet.public_subnet.id
}


resource "aws_security_group" "gcs_vm_security_group" {
  name        = "gcs-webserver"
  description = "Allow inbound HTTP and SSH from the Internet"
  vpc_id      = aws_vpc.myvpc.id
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  # implicit with AWS but Terraform requires this to be explicit
  egress {
    description      = "Allow all egress"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_instance" "webmev-gcs" {
  instance_type           = var.instance_type
  ami                     = var.ami
  key_name                = var.key_pair_name
  vpc_security_group_ids  = [aws_security_group.gcs_vm_security_group.id]
  subnet_id               = aws_subnet.public_subnet.id
  user_data               = file("provision.sh")
  ebs_block_device {
    delete_on_termination = false
    device_name           = "/dev/sdf"
    volume_size           = "${var.volume_size}"
    volume_type           = "${var.volume_type}"
  }
}
