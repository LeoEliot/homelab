terraform {
  required_providers {
    google = {
        source = "hashicorp/google"
        version = ">= 5.0"
    }

    kubernetes = {
        source = "hashicorp/kubernetes"
        version = ">= 2.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
}

module "cluster" {
  source = "./modules/cluster"
  
  project_id = var.project_id

}


module "ingress" {
  source = "./modules/infrastructure"
  
}