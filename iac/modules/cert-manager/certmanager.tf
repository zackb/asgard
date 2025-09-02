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

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.18.2"
  
  values = [
    yamlencode({
      crds = {
        enabled = true
      }
      global = {
        leaderElection = {
          namespace = "cert-manager"
        }
      }
    })
  ]
}

# Wait for CRDs to be ready
resource "time_sleep" "wait_for_cert_manager" {
  depends_on = [helm_release.cert_manager]
  create_duration = "30s"
}

resource "kubernetes_manifest" "letsencrypt_issuer" {
  depends_on = [time_sleep.wait_for_cert_manager]
  
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.email_address
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "traefik"
              }
            }
          }
        ]
      }
    }
  }
}
