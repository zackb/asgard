variable "enabled" {
  description = "to install nextcloud or not"
  type        = bool
  default     = true
}

variable "namespace" {
  description = "k8s namespace to install into"
  type        = string
  default     = "default"
}

variable "ingress_hostname" {
  description = "nextcloud hostname (e.g. cloud.bartel.com)"
  type        = string
}

variable "username" {
  description = "admin nextcloud username"
  type        = string
}

variable "password" {
  description = "admin nextcloud password"
  type        = string
}

variable "s3" {
  description = "s3 compatible object storage to store data"
  type = object({
    host       = string,
    access_key = string,
    secret_key = string,
    bucket     = string
    region     = string,
  })
}

variable "cluster_issuer" {
  description = "cert-manager cluster issuer name"
  type        = string
}