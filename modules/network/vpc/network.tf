resource "google_compute_network" "vpc" {
  name = var.name #"test-network"

  auto_create_subnetworks  = "false"
  enable_ula_internal_ipv6 = false
  routing_mode             = "REGIONAL"
}

resource "google_compute_subnetwork" "private" {
  name          = "${var.name}-subnetwork-private"
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.ip_cidr_range #"192.168.1.0/24"

  description = "private subnet in ${var.name} vpc"
}

resource "google_compute_firewall" "web" {
  count   = var.list_of_ports_web_fw != [] && var.source_ip_ranges_webfw != [] ? 1 : 0
  name    = "${var.name}-web-fw"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = var.list_of_ports_web_fw #["80", "443"]
  }

  source_ranges = var.source_ip_ranges_webfw #["10.0.0.0/8", "172.31.0.0/24"]
  source_tags   = ["web"]
}

resource "google_compute_firewall" "ssh" {
  count   = var.source_ip_ranges_sshfw != [] ? 1 : 0
  name    = "${var.name}-ssh-fw"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.source_ip_ranges_sshfw #["10.0.0.0/8", "172.31.0.0/24"]
  source_tags   = ["ssh"]
}
