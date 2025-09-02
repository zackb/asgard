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

resource "helm_release" "nats-streaming" {
  name       = "nats-streaming"
  repository = "https://nats-io.github.io/k8s/helm/charts/"
  namespace  = var.namespace
  chart      = "stan"
  version    = "0.4.0"

  set = [
    {
      name  = "replicas"
      value = var.replicas
    },
    {
      name  = "stan.logging.debug"
      value = false
    },
    {
      name  = "stan.clusterID"
      value = var.cluster_id
    },
    {
      name  = "store.type"
      value = var.store_type
    },
    {
      name  = "stan.nats.url"
      value = "nats://${var.nats.host}:${var.nats.port}"
    },
    {
      name  = "exporter.enabled"
      value = false
    }
  ]
}
