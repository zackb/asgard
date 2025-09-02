variable "namespace" {
  description = "namespace to install wintermute"
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

variable "nats" {
  description = "nats connection"
  type = object({
    host = string
    port = number
  })
}

variable "nats_streaming" {
  description = "nats streaming connection information"
  type = object({
    cluster_id = string
  })
}

variable "minio" {
  description = "minio connection"
  default = {
    endpoint      = ""
    root_user     = ""
    root_password = ""
    existing_secret_name = ""
  }
  type = object({
    endpoint              = string
    root_user             = string
    root_password         = string
    existing_secret_name  = string
  })
}
