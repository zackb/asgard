
resource "helm_release" "nats-streaming" {
  name       = "nats-streaming"
  repository = "https://nats-io.github.io/k8s/helm/charts/"
  namespace  = var.namespace
  chart      = "stan"
  version    = "0.4.0"

  set {
    name  = "replicas"
    value = var.replicas
  }

  set {
    name  = "stan.logging.debug"
    value = false
  }

  set {
    name  = "stan.clusterID"
    value = var.cluster_id
  }

  set {
    name  = "store.type"
    value = var.store_type
  }

  set {
    name  = "stan.nats.url"
    value = "nats://${var.nats.host}:${var.nats.port}"
  }

  # not arm, no prometheus
  set {
    name  = "exporter.enabled"
    value = false
  }
}
