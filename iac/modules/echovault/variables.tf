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
