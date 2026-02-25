terraform {
  backend "gcs" {
    bucket = "malefstorm-terraform-state"
    prefix = "malefstorm-cluster-dev/cluster"
  }
}