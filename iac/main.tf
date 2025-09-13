terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

# PROVIDERS
provider "kubernetes" {
  alias       = "asgard"
  config_path = pathexpand("${path.module}/${module.k3s.kubeconfig}")
}

provider "helm" {
  alias = "asgard"
  kubernetes = {
    config_path = pathexpand("${path.module}/${module.k3s.kubeconfig}")
  }
}

module "k3s" {
  source      = "./modules/k3s"
  k3s_version = "v1.33.4+k3s1"
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

module "nats-streaming" {
  source    = "./modules/nats-streaming"
  namespace = "default"

  providers = {
    kubernetes = kubernetes.asgard
    helm       = helm.asgard
  }

  nats = module.nats
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
  nats_streaming   = module.nats-streaming
  minio = {
    endpoint             = module.minio.endpoint
    existing_secret_name = module.minio.secret_name

    root_user     = module.minio.root_user
    root_password = module.minio.root_password
  }
  tls_enabled = var.tls_enabled
}

module "minio" {
  source = "./modules/minio"

  providers = {
    kubernetes = kubernetes.asgard
    helm       = helm.asgard
  }

  release_name = "minio"
  namespace    = "default"

  storage_size = "10Gi"
  mode         = "distributed"
  replicas     = 4

  ingress = {
    enabled = false
  }
}



module "cert-manager" {
  source = "./modules/cert-manager"
  providers = {
    kubernetes = kubernetes.asgard
    helm       = helm.asgard
  }

  email_address = var.email_address
  # set to true to use prod Let's Encrypt
  lets_encrypt_prod = true
}

/*
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
*/

module "postgresql" {
  source = "./modules/postgresql"

  providers = {
    kubernetes = kubernetes.asgard
    helm       = helm.asgard
  }

  namespace    = "db"
  storage_size = "5Gi"
  init_dbs = [
    {
      namespace = "default"
      name      = "echovault"
      username  = "echovault"
      password  = random_password.echovault_db_password.result
    }
  ]
}

resource "random_password" "echovault_db_password" {
  length  = 16
  special = false
}

module "echovault" {
  source = "./modules/echovault"

  providers = {
    kubernetes = kubernetes.asgard
    helm       = helm.asgard
  }

  ingress_hostname = "ev.${var.zone}"
  tls_enabled      = var.tls_enabled
  jwks_json        = var.jwks_json
  db_secret_name   = "echovault-db"
  minio = {
    endpoint             = module.minio.endpoint
    existing_secret_name = module.minio.secret_name

    root_user     = module.minio.root_user
    root_password = module.minio.root_password
  }
}

module "docker-registry" {
  source = "./modules/docker-registry"
  providers = {
    kubernetes = kubernetes.asgard
    helm       = helm.asgard
  }
}

output "registry_username" {
  value = module.docker-registry.registry_username
}

output "registry_password" {
  value     = module.docker-registry.registry_password
  sensitive = true
}
