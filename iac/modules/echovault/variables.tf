variable "namespace" {
  description = "namespace to install echovault"
  type        = string
  default     = "default"
}

variable "ingress_hostname" {
  description = "hostname to use for ingress"
  type        = string
}

variable "tls_enabled" {
  description = "ssl enabled or not"
  type        = bool
  default     = false
}

variable "jwks_json" {
  description = "JWKS JSON content for echovault auth"
  type        = string
}

variable "db_secret_name" {
  description = "Kubernetes secret name containing the database DSN in DATABASE_URL key"
  type        = string
  default     = "echovault-db"
}

variable "replicas" {
  description = "number of replicas for echovault deployment"
  type        = number
  default     = 1
}

variable "minio" {
  description = "minio connection"
  default = {
    endpoint             = ""
    root_user            = ""
    root_password        = ""
    existing_secret_name = ""
  }
  type = object({
    endpoint             = string
    root_user            = string
    root_password        = string
    existing_secret_name = string
  })
}
