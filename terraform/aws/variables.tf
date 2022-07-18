variable "instance_type" {
  description = "Instance type for EC2 server"
  default = "t2.medium"
}

variable "ami" {
  description = "AWS machine image ID"
  default = "ami-08d4ac5b634553e16"
}

variable "volume_size" {
  description = "Size of the disk in GiB"
  default = "50"
}

variable "volume_type" {
  description = "Type of EBS volume"
  default = "gp3"
}