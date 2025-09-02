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

resource "random_password" "registry_password" {
  length  = 16
  special = true
}

resource "kubernetes_secret" "registry_auth" {
  metadata {
    name      = "registry-auth"
    namespace = "default"
  }
  
  data = {
    htpasswd = "admin:${bcrypt(random_password.registry_password.result)}"
  }
}

resource "helm_release" "docker_registry" {
  name             = "registry"
  repository       = "https://helm.twun.io"
  chart            = "docker-registry"
  namespace        = "default"
  create_namespace = true
  
  depends_on = [kubernetes_secret.registry_auth]
  
  values = [
    yamlencode({
      persistence = {
        enabled = true
        size    = "20Gi"
      }
      ingress = {
        enabled = true
        hosts   = ["registry.bartel.com"]
        ingressClassName = "traefik"
        className = "traefik"
        annotations = {
          "kubernetes.io/ingress.class" = "traefik"
          "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
        }
        tls = [
          {
            secretName = "registry-tls"
            hosts      = ["registry.bartel.com"]
          }
        ]
      }
      secrets = {
        htpasswd = ""
      }
      existingSecret = "registry-auth"
    })
  ]
}

resource "kubernetes_secret" "registry_pull_secret" {
  metadata {
    name      = "registry-secret"
    namespace = "default"  # TODO
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "registry.bartel.com" = {
          username = "admin"
          password = random_password.registry_password.result
          auth     = base64encode("admin:${random_password.registry_password.result}")
        }
      }
    })
  }
}
