terraform {
  required_version = ">= 1.3"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.2"
    }
  }
}

locals {
  ns = var.namespace
}

resource "kubernetes_namespace" "this" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = local.ns
  }
}

resource "random_password" "root_password" {
  length  = 24
  special = false
}

resource "random_password" "root_user" {
  length  = 12
  special = false
  upper   = true
  lower   = true
  number  = true
}

resource "kubernetes_secret" "creds" {
  count = var.existing_secret_name == null ? 1 : 0

  metadata {
    name      = "${var.release_name}-creds"
    namespace = local.ns
  }

  data = {
    rootUser     = base64encode(var.root_user != null ? var.root_user : random_password.root_user.result)
    rootPassword = base64encode(var.root_password != null ? var.root_password : random_password.root_password.result)
  }

  type = "Opaque"
}

locals {
  secret_name = var.existing_secret_name != null ? var.existing_secret_name : kubernetes_secret.creds[0].metadata[0].name

  values = {
    mode           = var.mode
    replicas       = var.replicas
    existingSecret = local.secret_name

    image = {
      repository = "quay.io/minio/minio"
      tag        = var.image_tag
      pullPolicy = "IfNotPresent"
    }

    persistence = {
      enabled      = true
      storageClass = var.storage_class != null ? var.storage_class : ""
      size         = var.storage_size
      accessMode   = "ReadWriteOnce"
    }

    service = {
      type = var.service_type
      port = 9000
    }

    consoleService = {
      type = "ClusterIP"
      port = 9001
    }

    resources     = var.resources
    nodeSelector  = var.node_selector
    tolerations   = var.tolerations
    affinity      = var.affinity != null ? var.affinity : {}
    // ingress       = var.ingress
    ingress = {
      enabled          = false
      ingressClassName = ""
      annotations      = {}
      hosts            = []
      tls              = []
    }

    consoleIngress = {
      enabled          = false
      ingressClassName = ""
      annotations      = {}
      hosts            = []
      tls              = []
    }
  }
}

resource "helm_release" "minio" {
  name       = var.release_name
  repository = "https://charts.min.io/"
  chart      = "minio"
  version    = var.chart_version
  namespace  = local.ns
  timeout    = 600
  wait       = true
  create_namespace = false

  values = [yamlencode(local.values)]
}

