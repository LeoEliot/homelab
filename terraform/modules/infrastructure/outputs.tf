
output "ingress_nginx_ip" {
  value = google_compute_address.external_ip.address
}