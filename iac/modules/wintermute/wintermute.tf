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

resource "helm_release" "wintermute" {
  name      = "wintermute"
  namespace = var.namespace
  chart     = "../../wintermute/helm/wintermute"
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
      
      mute = {
        image   = "registry.bartel.com/mute"
        imagePullSecrets = "registry-secret"
        message = "winter is coming?!?"
        
        nats = {
          host = var.nats.host
          port = var.nats.port
        }
        
        stan = {
          cluster_id = var.nats_streaming.cluster_id
        }
        
        db = {
          host = ""
        }
        
        fs = {
          endpoint        = var.minio.endpoint
          accessKey        = var.minio.root_user
          secretKey       = var.minio.root_password
        }
      }
    })
  ]
}
