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

variable "minio" {
  description = "minio connection"
  type = object({
    endpoint   = string
    access_key = string
    secret_key = string
  })
}
