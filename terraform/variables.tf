variable "project_id" {
  description = "GCP project ID"
}

variable "environment" {
  description = "Sets which environment (dev, prod) we are deploying in."
}

variable "credentials_file" {
  description = "Path to JSON file with GCP service account key"
}

variable "region" {
  default = "us-east4"
}

variable "zone" {
  default = "us-east4-c"
}

variable disk_size_gb {
  description = "Size of the disk in GB"
  type = number
  default = 20
}

variable gcp_machine_type {
    description = "The type of GCP machine, e.g e2-standard-2"
    default = "e2-standard-2"
}