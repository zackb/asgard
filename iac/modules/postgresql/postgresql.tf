terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
  }
}

resource "kubernetes_namespace" "db" {
  metadata {
    name = var.namespace
  }
}

resource "random_password" "pg_password" {
  length  = 24
  special = false
}

locals {
  init_sql = join("\n\n", [
    for db in var.init_dbs : <<EOT
CREATE DATABASE ${db.name};
CREATE USER ${db.username} WITH ENCRYPTED PASSWORD '${db.password}';
GRANT ALL PRIVILEGES ON DATABASE ${db.name} TO ${db.username};
\connect ${db.name}
GRANT USAGE, CREATE ON SCHEMA public TO ${db.username};
EOT
  ])
}


resource "helm_release" "postgresql" {
  name       = "postgresql"
  namespace  = kubernetes_namespace.db.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "16.7.27"

  create_namespace = false
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      auth = {
        postgresPassword = random_password.pg_password.result
      }

      primary = {
        persistence = {
          enabled      = true
          size         = var.storage_size
          storageClass = "local-path"
        }

        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }

        configurationParameters = {
          shared_buffers       = "64MB"
          work_mem             = "2MB"
          maintenance_work_mem = "16MB"
          max_connections      = "50"
          wal_level            = "minimal" # disable WAL for dev
        }

        initdbScripts = {
          "initdb.sql" = local.init_sql
        }
      }
    })
  ]
}

resource "kubernetes_secret" "db_users" {
  for_each = { for db in var.init_dbs : db.username => db }

  metadata {
    name      = "${each.value.username}-db"
    namespace = each.value.namespace
  }

  data = {
    DATABASE_URL = "postgres://${each.value.username}:${each.value.password}@${helm_release.postgresql.name}.${kubernetes_namespace.db.metadata[0].name}.svc.cluster.local:5432/${each.value.name}?sslmode=disable"
  }

  type = "Opaque"
}

