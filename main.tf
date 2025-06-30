
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_address" "meilisearch_ip" {
  name = "meilisearch-static-ip"
}

resource "google_compute_instance" "meilisearch_vm" {
  name         = "meilisearch-vm"
  machine_type = "e2-micro"
  zone         = var.zone
  tags         = ["meilisearch"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
    }
  }

  network_interface {
    network       = "default"
    access_config {
      nat_ip = google_compute_address.meilisearch_ip.address
    }
  }

  metadata_startup_script = file("startup.sh")

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_firewall" "meilisearch_firewall" {
  name    = "allow-meilisearch"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["7700"]
  }

  target_tags   = ["meilisearch"]
  source_ranges = ["0.0.0.0/0"]
}

output "meilisearch_static_ip" {
  value = google_compute_address.meilisearch_ip.address
}