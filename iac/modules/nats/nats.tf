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

resource "helm_release" "nats" {
  name       = "nats"
  repository = "https://nats-io.github.io/k8s/helm/charts/"
  namespace  = var.namespace
  chart      = "nats"
  version    = "0.4.0"

  set = [
    {
      name  = "cluster.enabled"
      value = "true"
    },
    {
      name  = "reloader.enabled"
      value = "false"
    },
    {
      name  = "exporter.enabled"
      value = "false"
    },
    {
      name  = "natsbox.enabled"
      value = "false"
    }
  ]
}
