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

resource "aws_instance" "webmev-gcs" {
  instance_type           = var.instance_type
  ami                     = var.ami
  user_data               = file("provision.sh")
  ebs_block_device {
    delete_on_termination = false
    device_name           = "/dev/sdf"
    volume_size           = "${var.volume_size}"
    volume_type           = "${var.volume_type}"
  }
}
