# PROVIDERS
provider "kubernetes" {
  alias = "asgard"

  load_config_file = true
  config_path      = "${path.module}/${module.k3s.kubeconfig}"
}

provider "helm" {
  alias = "asgard"

  kubernetes {
    load_config_file = true
    config_path      = "${path.module}/${module.k3s.kubeconfig}"
  }
  debug = true
}

data "helm_repository" "stable" {
  provider = helm.asgard
  name     = "stable"
  url      = "https://kubernetes-charts.storage.googleapis.com"
}

module "k3s" {
  source      = "./modules/k3s"
  k3s_version = "v1.17.5+k3s1"
  master      = var.master
  nodes       = var.nodes
}

# APPS
module "nats" {
  source    = "./modules/nats"
  namespace = "default"

  providers = {
    kubernetes = kubernetes.asgard
    helm       = helm.asgard
  }
}

module "minio" {
  source    = "./modules/minio"
  namespace = "default"

  providers = {
    kubernetes = kubernetes.asgard
    helm       = helm.asgard
  }

  config = {
    # minio requires at least 4 nodes in distributed mode
    replicas     = max(length(var.nodes) + 1, 4)
    storage_size = "4Gi"
    port         = 9000
  }
}

module "cert-manager" {
  source     = "./modules/cert-manager"
  kubeconfig = module.k3s.kubeconfig

  providers = {
    kubernetes = kubernetes.asgard
    helm       = helm.asgard
  }

  email_address = var.email_address
  # set to true to use prod Let's Encrypt
  lets_encrypt_prod = false
  certificates = var.tls_enabled ? [
    {
      domain    = local.hostname
      namespace = module.wintermute.namespace
    }
  ] : []
}

locals {
  hostname = "${var.name}.${var.zone}"
}

module "wintermute" {
  source = "./modules/wintermute"

  providers = {
    kubernetes = kubernetes.asgard
    helm       = helm.asgard
  }

  ingress_hostname = local.hostname
  nats             = module.nats
  minio            = module.minio
  tls_enabled      = var.tls_enabled
}

module "nextcloud" {
  source = "./modules/nextcloud"

  providers = {
    kubernetes = kubernetes.asgard
    helm       = helm.asgard
  }

  enabled          = var.applications.nextcloud
  namespace        = "default"
  ingress_hostname = "cloud.${local.hostname}"
  cluster_issuer   = module.cert-manager.cluster_issuer

  s3       = var.nextcloud.s3
  username = var.nextcloud.username
  password = var.nextcloud.password
}

/*
module "docker-registry" {
  source = "./modules/docker-registry"
}
*/
