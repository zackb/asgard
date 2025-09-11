variable "kubeconfig" {
  description = "Path to kubeconfig that points at your k3s cluster"
  type        = string
  default     = "~/.kube/config"
}

variable "namespace" {
  description = "Namespace to install PostgreSQL into"
  type        = string
  default     = "databases"
}

variable "storage_size" {
  description = "PVC size for PostgreSQL primary"
  type        = string
  default     = "10Gi"
}

variable "init_dbs" {
  description = "List of DBs to create, each with username and password"
  type = list(object({
    namespace = string
    name      = string
    username  = string
    password  = string
  }))
  default = []
}

