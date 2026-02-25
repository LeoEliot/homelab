provider "google" {
  project = var.project_id
  region = var.region
}

data "google_client_config" "default" {}

data "google_container_cluster" "gke" {
    name = var.cluster_name
    location = var.zone
}

provider "kubernetes" {
  host = "https://${data.google_container_cluster.gke.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
  token = data.google_client_config.default.access_token
}

provider "helm" {
  kubernetes = {
    host = "https://${data.google_container_cluster.gke.endpoint}"
    cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
    token = data.google_client_config.default.access_token
  }
}