terraform {
  required_version = "~> 1.0.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.60.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

resource "google_compute_network" "mev_gcs_network" {
  name = "webmev-${terraform.workspace}-gcs-network"
}

resource "google_compute_firewall" "gcs_firewall" {
  name    = "webmev-${terraform.workspace}-gcs-firewall"
  network = google_compute_network.mev_gcs_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "50000-51000"]
  }
  
  target_tags = ["gcs-ports"]
}


resource "google_compute_instance" "webmev_gcs" {
  name                    = "webmev-${terraform.workspace}-gcs"
  machine_type            = var.gcp_machine_type
  tags                    = ["gcs-ports"]

  metadata_startup_script = templatefile("provision.sh",
    {
      environment = terraform.workspace
    }
  )

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size = var.disk_size_gb
    }
  }

  network_interface {
    network = google_compute_network.mev_gcs_network.name
    access_config {
    }
  }
}


