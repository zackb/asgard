resource "helm_release" "wintermute" {
  name      = "wintermute"
  namespace = var.namespace
  chart     = "../../wintermute/helm/wintermute"
  version   = "0.0.1"
  timeout   = 600

  set = [
    {
      name  = "ingress.hostname"
      value = var.ingress_hostname
    },
    {
      name  = "ingress.tls.enabled"
      value = var.tls_enabled
    },
    {
      name = "ingress.tls.secretName"
      value = "${var.ingress_hostname}-cert"
    },
    {
      name  = "mute.message"
      value = "winter is coming?"
    },
    {
      name  = "mute.nats.host"
      value = var.nats.host
    },
    {
      name  = "mute.nats.port"
      value = var.nats.port
    },
    {
      name  = "mute.stan.cluster_id"
      value = var.nats_streaming.cluster_id
    },
    {
      # Disable cockroachdb and minio
      name  = "mute.db.host"
      value = ""
    }
    /*
    {
      name  = "mute.fs.endpoint"
      value = var.minio.endpoint
    },
    {
      name  = "mute.fs.accessKey"
      value = var.minio.access_key
    },
    {
      name  = "mute.fs.secretKey"
      value = var.minio.secret_key
    }
    */
  ]
}
