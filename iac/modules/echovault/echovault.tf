terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
  }
}

resource "helm_release" "echovault" {
  name      = "echovault"
  namespace = var.namespace
  chart     = "../../echovault/deployments/helm/echovault"
  version   = "0.0.1"
  timeout   = 600
  
  values = [
    yamlencode({
      ingress = {
        hostname = var.ingress_hostname
        tls = {
          enabled    = var.tls_enabled
          secretName = "${var.ingress_hostname}-cert"
        }
        additionalAnnotations = {
          "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
        }
      }
      
      echovault = {
        image   = "registry.bartel.com/echovault"
        imagePullSecrets = "registry-secret"
      }
    })
  ]
}
