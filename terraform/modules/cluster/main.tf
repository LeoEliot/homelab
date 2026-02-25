provider "google" {
  project = var.project_id
  region = var.region
}

# Enable the GKE APIs using Terraform resources
resource "google_project_service" "container_api" {
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute_api" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
  # Ensure compute API is enabled before the container API depends on it
  depends_on         = [google_project_service.container_api]
}

resource "google_container_cluster" "main" {
  name = var.cluster_name
  location = var.zone

  remove_default_node_pool = true
  initial_node_count = 1

  network = "default"
  subnetwork = "default"

  ip_allocation_policy {}

  deletion_protection = false

  lifecycle {
    ignore_changes = [ 
        initial_node_count,
        enable_autopilot,
        enable_tpu,
        enable_intranode_visibility,
        datapath_provider,
     ]
  }
}

resource "google_container_node_pool" "main_nodes" {
  name = "main-pool"
  location = var.zone
  cluster = google_container_cluster.main.name

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    machine_type = "e2-standard-4"
    service_account = "malefstorm-gke-nodes@malefstorm.iam.gserviceaccount.com"
    oauth_scopes = [ "cloud-platform" ]
    labels = {
        workload = "main"
    }
    tags = ["main"]
  }
}