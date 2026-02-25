variable "project_id" {
  description = "GCP Project"
  type = string
  default = "malefstorm"
}

variable "region" {
  description = "GCP Region"
  type = string
  default = "us-west1"
}

variable "zone" {
    description = "GCP Zone"
    type = string
    default = "us-west1-a"
}

variable "cluster_name" {
  description = "Cluster Name"
  type = string
  default = "kubetrain"
}

variable "email" {
  type = string
  default = "vakfuder@gmail.com"
}