output "cluster_name" {
  value = module.cluster.kubernetes_cluster_name
}

output "cluster_endpoints" {
  value = module.cluster.kubernetes_cluster_endpoint
}

output "ingress_nginx_ip" {
  value = module.ingress.ingress_nginx_ip
}

output "vpc_network" {
  value = module.vpc.vpc_network
}

output "vpc_network_public" {
  value = module.vpc.vpc_public_network
}