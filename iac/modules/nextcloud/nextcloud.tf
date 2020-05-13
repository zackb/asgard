resource "helm_release" "nextcloud" {
  count     = var.enabled ? 0 : 1
  name      = "nextcloud"
  namespace = var.namespace
  chart     = "stable/nextcloud"
  version   = "1.10.0"

  values = [
    data.template_file.nextcloud-values.0.rendered,
  ]
}

data "template_file" "nextcloud-values" {
  count    = var.enabled ? 0 : 1
  template = file("${path.module}/nextcloud.yaml")

  vars = {
    hostname       = var.ingress_hostname
    cluster_issuer = var.cluster_issuer
    username       = var.username
    password       = var.password
    s3_hostname    = var.s3.host
    access_key     = var.s3.access_key
    secret_key     = var.s3.secret_key
    bucket         = var.s3.bucket
    region         = var.s3.region
  }
}
