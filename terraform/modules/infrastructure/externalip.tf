resource "google_compute_address" "external_ip" {
  name = "kubetrain-cluster-static-ip"
  region = var.region
}