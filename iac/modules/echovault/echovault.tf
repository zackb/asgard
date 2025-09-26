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

resource "kubernetes_secret" "jwks" {
  metadata {
    name = "jwks-secret"
  }

  data = {
    "jwks.json" = var.jwks_json
  }

  type = "Opaque"
}


resource "helm_release" "echovault" {
  name      = "echovault"
  namespace = var.namespace
  chart     = "../../echovault/deployments/helm/echovault"
  version   = "0.0.3"
  timeout   = 600

  values = [
    yamlencode({
      ingress = {
        enabled  = true
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
        image            = "registry.bartel.com/echovault/echovault"
        imagePullSecrets = "registry-secret"
        replicas         = var.replicas
        jwksSecretName   = kubernetes_secret.jwks.metadata[0].name
        dbSecretName     = var.db_secret_name
        encryptionKey    = "Z4fD6g8H9jK3mN5pQ2sV7xY1zB4eF6gH"
        minio = {
          enabled        = var.minio.endpoint != ""
          endpoint       = var.minio.endpoint
          existingSecret = var.minio.existing_secret_name
        }
      }
    })
  ]
}
