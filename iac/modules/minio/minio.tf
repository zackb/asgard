data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "minio" {
  name      = "minio"
  namespace = var.namespace
  chart     = "stable/minio"
  version   = "5.0.23"
  timeout   = 600

  # https://github.com/jessestuart/minio-multiarch
  # https://hub.docker.com/r/jessestuart/minio/tags
  set {
    name  = "image.repository"
    value = "jessestuart/minio"
  }

  set {
    name  = "image.tag"
    value = "RELEASE.2020-02-07T23-28-16Z-arm"
  }

  set {
    name  = "mcImage.repository"
    value = "jessestuart/mc"
  }

  set {
    name  = "mcImage.tag"
    value = "RELEASE.2020-02-07T23-28-16Z-arm"
  }

  set {
    name  = "mode"
    value = var.config.replicas > 1 ? "distributed" : "standalone"
  }

  set {
    name  = "replicas"
    value = var.config.replicas
  }

  set {
    name  = "persistence.enabled"
    value = true
  }

  set {
    name  = "persistence.size"
    value = var.config.storage_size
  }

  set {
    name  = "accessKey"
    value = random_string.minio-access-key.result
  }

  set {
    name  = "secretKey"
    value = random_string.minio-secret-key.result
  }

  set {
    name  = "service.port"
    value = var.config.port
  }
}

resource "random_string" "minio-access-key" {
  length  = 32
  special = false
}

resource "random_string" "minio-secret-key" {
  length  = 32
  special = false
}
