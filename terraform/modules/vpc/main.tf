provider "google" {
  project = var.project_id
  region = var.region
}

resource "google_compute_network" "home" {
  name = "home-network"
  auto_create_subnetworks = false
  routing_mode = "REGIONAL"
  mtu = 1460
}

resource "google_compute_subnetwork" "public" {
  name = "home-public"
  network = google_compute_network.home.self_link
  ip_cidr_range = "10.0.1.0/24"
  region = var.region
  depends_on = [ google_compute_network.home ]
}

resource "google_compute_subnetwork" "private" {
  name = "home-private"
  network = google_compute_network.home.self_link
  ip_cidr_range = "10.0.2.0/24"
  region = var.region
  private_ip_google_access = true
  depends_on = [ google_compute_network.home ]
}