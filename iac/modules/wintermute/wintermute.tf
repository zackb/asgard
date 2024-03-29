resource "helm_release" "wintermute" {
  name      = "wintermute"
  namespace = var.namespace
  chart     = "../../wintermute/helm/wintermute"
  version   = "0.3.8"
  timeout   = 600

  set {
    name  = "ingress.hostname"
    value = var.ingress_hostname
  }

  set {
    name  = "ingress.tls.enabled"
    value = var.tls_enabled
  }

  set {
    name = "ingress.tls.secretName"
    value = "${var.ingress_hostname}-cert"
  }

  set {
    name  = "mute.message"
    value = "winter is coming?"
  }

  set {
    name  = "mute.nats.host"
    value = var.nats.host
  }

  set {
    name  = "mute.nats.port"
    value = var.nats.port
  }

  set {
    name  = "mute.stan.cluster_id"
    value = var.nats_streaming.cluster_id
  }

  # Disable cockroachdb and minio
  set {
    name  = "mute.db.host"
    value = ""
  }

  set {
    name  = "mute.fs.endpoint"
    value = var.minio.endpoint
  }

  set {
    name  = "mute.fs.accessKey"
    value = var.minio.access_key
  }

  set {
    name  = "mute.fs.secretKey"
    value = var.minio.secret_key
  }
}
