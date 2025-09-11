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
