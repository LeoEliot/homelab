output "vpc_network" {
  value = google_compute_network.home.name
}

output "vpc_public_network" {
  value = google_compute_subnetwork.public.name
}