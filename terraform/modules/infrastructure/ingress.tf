resource "kubernetes_namespace_v1" "ingress_nginx" {
    metadata {
      name = "ingress-nginx"

    }

    lifecycle {
      ignore_changes = [ metadata ]
    }
}

resource "helm_release" "ingress_nginx" {
  name = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  namespace = kubernetes_namespace_v1.ingress_nginx.metadata[0].name

  force_update = false
  recreate_pods = false
  cleanup_on_fail = true
  timeout = 900
  wait = true
  set = [ {
    name = "controller.service.loadBalancerIP"
    value = google_compute_address.external_ip.address
  } ,
  {
    name = "control.service.type"
    value = "LoadBalancer"
  }]

  depends_on = [ 
    kubernetes_namespace_v1.ingress_nginx,
    google_compute_address.external_ip
   ]
}