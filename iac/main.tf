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

locals {
  worker_names = [
    for node in var.nodes : node.name
  ]
  worker_nodes = [
    for node in var.nodes : {
      name = node.name
      ip   = node.host
      labels = {
        "node.kubernetes.io/pool"        = "service-pool"
        "node-role.kubernetes.io/worker" = "true"
      }
      taints = {}
      connection = {
        type        = "ssh"
        host        = node.host
        user        = "root"
        private_key = file(node.private_key)
      }
    }
  ]
}

module "k3s" {
  source = "./modules/k3s"
  master = var.master
  nodes  = zipmap(local.worker_names, local.worker_nodes)
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
    replicas     = 1
    storage_size = "4Gi"
    port         = 9000
  }
}

module "wintermute" {
  source = "./modules/wintermute"

  providers = {
    kubernetes = kubernetes.asgard
    helm       = helm.asgard
  }

  nats  = module.nats
  minio = module.minio
}

/*
module "docker-registry" {
  source = "./modules/docker-registry"
}

module "cert-manager" {
  source     = "./modules/cert-manager"
  kubeconfig = module.k3s.kubeconfig
  namespace  = "kube-system"
}
*/
