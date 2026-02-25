output "kubernetes_cluster_name" {
  value = google_container_cluster.main.name
}

output "kubernetes_cluster_endpoint" {
  value = google_container_cluster.main.endpoint
}