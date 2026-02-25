#!/bin/bash

set -euo pipefail

ED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


NAMESPACE_INGRESS="ingress-nginx"
NAMESPACE_CERT_MANAGER="cert-manager"
NAMESPACE_MONITORING="monitoring"

# Helm repository URLs
INGRESS_NGINX_REPO="https://kubernetes.github.io/ingress-nginx"
CERT_MANAGER_REPO="https://charts.jetstack.io"
PROMETHEUS_COMMUNITY_REPO="https://prometheus-community.github.io/helm-charts"

CERT_MANAGER_VERSION="v1.19.3"
INGRESS_NGINX_VERSION="4.14.3"
PROMETHEUS_STACK_VERSION="82.3.0"
LETSENCRYPT_EMAIL="vanfonmaier@gmail.com" #Change this to actial email!

print_step() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}STEP: $1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_info() {
    echo -e "${YELLOW}INFO: $1${NC}"
}

print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

check_prerequisites() {
    print_step "Checking prerequisites"
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install it first."
        exit 1
    fi
    print_info "kubectl is installed: $(kubectl version --client)"
    
    # Check if helm is installed
    if ! command -v helm &> /dev/null; then
        print_error "helm is not installed. Please install it first."
        exit 1
    fi
    print_info "helm is installed: $(helm version --short)"
    
    # Check if we can connect to the cluster
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    print_info "Connected to Kubernetes cluster successfully"
    
    # Check cluster nodes
    NODES=$(kubectl get nodes -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}')
    if [[ "$NODES" != *"True"* ]]; then
        print_error "No ready nodes found in the cluster"
        exit 1
    fi
    print_info "Cluster nodes are ready"
}

create_namespaces() {
    print_step "Creating namespaces"
    
    for ns in $NAMESPACE_INGRESS $NAMESPACE_CERT_MANAGER $NAMESPACE_MONITORING; do
        if kubectl get namespace $ns &> /dev/null; then
            print_info "Namespace $ns already exists"
        else
            kubectl create namespace $ns
            print_info "Namespace $ns created"
        fi
    done
}

install_ingress_nginx() {
    print_step "Installing ingress-nginx"
    
    # Add helm repository
    #helm repo add ingress-nginx $INGRESS_NGINX_REPO
    #helm repo update
    
    # Install or upgrade ingress-nginx
    if helm list -n $NAMESPACE_INGRESS | grep -q ingress-nginx; then
        print_info "ingress-nginx is already installed. Upgrading..."
        helm upgrade ingress-nginx ingress-nginx/ingress-nginx \
            --namespace $NAMESPACE_INGRESS \
            --version $INGRESS_NGINX_VERSION \
            --set controller.service.type=LoadBalancer \
            --wait
    else
        print_info "Installing ingress-nginx..."
        helm install ingress-nginx ingress-nginx/ingress-nginx \
            --namespace $NAMESPACE_INGRESS \
            --version $INGRESS_NGINX_VERSION \
            --set controller.service.type=LoadBalancer \
            --wait
    fi
    
    # Wait for the ingress controller to be ready
    print_info "Waiting for ingress-nginx controller to be ready..."
    kubectl wait --namespace $NAMESPACE_INGRESS \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=120s
    
    # Get the ingress controller service details
    INGRESS_SVC=$(kubectl get svc -n $NAMESPACE_INGRESS ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    print_success "ingress-nginx installed successfully. LoadBalancer IP: $INGRESS_SVC"
}

install_cert_manager() {
    print_step "Installing cert-manager"
    
    # Add helm repository
    #helm repo add jetstack $CERT_MANAGER_REPO
    #helm repo update
    
    # Apply CRDs
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/$CERT_MANAGER_VERSION/cert-manager.crds.yaml
    
    # Install or upgrade cert-manager
    if helm list -n $NAMESPACE_CERT_MANAGER | grep -q cert-manager; then
        print_info "cert-manager is already installed. Upgrading..."
        helm upgrade cert-manager jetstack/cert-manager \
            --namespace $NAMESPACE_CERT_MANAGER \
            --version $CERT_MANAGER_VERSION \
            --set installCRDs=false \
            --set global.leaderElection.namespace=$NAMESPACE_CERT_MANAGER \
            --wait
    else
        print_info "Installing cert-manager..."
        helm install cert-manager jetstack/cert-manager \
            --namespace $NAMESPACE_CERT_MANAGER \
            --version $CERT_MANAGER_VERSION \
            --set installCRDs=false \
            --set global.leaderElection.namespace=$NAMESPACE_CERT_MANAGER \
            --create-namespace \
            --wait
    fi
    
    # Wait for cert-manager pods to be ready
    print_info "Waiting for cert-manager pods to be ready..."
    kubectl wait --namespace $NAMESPACE_CERT_MANAGER \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/instance=cert-manager \
        --timeout=120s
    
    # Create a ClusterIssuer for Let's Encrypt
    print_info "Creating Let's Encrypt ClusterIssuer..."
    
    cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: $LETSENCRYPT_EMAIL
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: $LETSENCRYPT_EMAIL
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
    
    print_success "cert-manager installed successfully"
}

install_kube_prometheus_stack() {
    print_step "Installing kube-prometheus-stack"

if helm list -n $NAMESPACE_MONITORING | grep -q prometheus-stack; then
        print_info "kube-prometheus-stack is already installed. Upgrading..."
        helm upgrade prometheus-stack prometheus-community/kube-prometheus-stack \
            --namespace $NAMESPACE_MONITORING \
            --version $PROMETHEUS_STACK_VERSION \
            --values /kube-prometheus-stack/values.yaml \
            --wait
    else
        print_info "Installing kube-prometheus-stack..."
        helm install prometheus-stack prometheus-community/kube-prometheus-stack \
            --namespace $NAMESPACE_MONITORING \
            --version $PROMETHEUS_STACK_VERSION \
            --values ./kube-prometheus-stack/values.yaml \
            --create-namespace \
            --wait
    fi
    
    # Wait for all pods to be ready
    print_info "Waiting for kube-prometheus-stack pods to be ready..."
    kubectl wait --namespace $NAMESPACE_MONITORING \
        --for=condition=ready pod \
        --selector=release=prometheus-stack \
        --timeout=300s
    
    # Clean up temp file
    rm -f /tmp/prometheus-values.yaml
    
    print_success "kube-prometheus-stack installed successfully"
}

verify_installations() {
    print_step "Verifying installations"
    
    echo -e "\n${GREEN}=== Ingress Controller ===${NC}"
    kubectl get pods -n $NAMESPACE_INGRESS
    
    echo -e "\n${GREEN}=== Cert Manager ===${NC}"
    kubectl get pods -n $NAMESPACE_CERT_MANAGER
    
    echo -e "\n${GREEN}=== Monitoring Stack ===${NC}"
    kubectl get pods -n $NAMESPACE_MONITORING
    
    echo -e "\n${GREEN}=== Cluster Issuers ===${NC}"
    kubectl get clusterissuer
}

display_summary() {
    print_step "Installation Summary"
    
    INGRESS_IP=$(kubectl get svc -n $NAMESPACE_INGRESS ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
    GRAFANA_PASSWORD=$(kubectl get secret -n $NAMESPACE_MONITORING prometheus-stack-grafana -o jsonpath='{.data.admin-password}' 2>/dev/null | base64 --decode || echo "prom-operator")
    
    echo -e "${GREEN}✅ All components installed successfully!${NC}"
    echo ""
    echo "=== Access Information ==="
    echo "Ingress Controller IP: $INGRESS_IP"
    echo ""
    echo "=== Grafana ==="
    echo "Access via: kubectl port-forward -n $NAMESPACE_MONITORING svc/prometheus-stack-grafana 3000:80"
    echo "Username: admin"
    echo "Password: admin"
    echo ""
    echo "=== Prometheus ==="
    echo "Access via: kubectl port-forward -n $NAMESPACE_MONITORING svc/prometheus-stack-kube-prom-prometheus 9090:9090"
    echo ""
    echo "=== Alertmanager ==="
    echo "Access via: kubectl port-forward -n $NAMESPACE_MONITORING svc/prometheus-stack-kube-prom-alertmanager 9093:9093"
    echo ""
    echo "=== Useful Commands ==="
    echo "Watch pods: watch kubectl get pods --all-namespaces"
    echo "Check ingress: kubectl get ingress --all-namespaces"
    echo "Check certificates: kubectl get certificates --all-namespaces"
    echo ""
    echo "To create a test ingress with TLS:"
    echo "1. Deploy a test application"
    echo "2. Create an ingress with annotation: cert-manager.io/cluster-issuer: letsencrypt-staging"
}

main() {
    print_step "Starting Kubernetes Cluster Bootstrap"
    echo "This script will install:"
    echo "  - ingress-nginx"
    echo "  - cert-manager with Let's Encrypt issuers"
    echo "  - kube-prometheus-stack (Prometheus, Grafana, Alertmanager)"
    echo ""
    
    # Confirm before proceeding
    read -p "Do you want to continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi
    
    # Run installation steps
    check_prerequisites
    create_namespaces
    install_ingress_nginx
    install_cert_manager
    install_kube_prometheus_stack
    verify_installations
    display_summary

    print_success "Bootstrap complete!"
}



# Run main function
main "$@"