variable "name" {
  type        = string
  description = "name of the cluster"
  default     = "asgard"
}

module "k3s" {
  source = "./modules/k3s"
  master = {
    name        = "odin"
    host        = "192.168.1.200"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
  }
}

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
