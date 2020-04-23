variable "namespace" {
  description = "namespace to install nats"
  type        = string
  default     = "default"
}

variable "config" {
  type = object({
    replicas     = string
    storage_size = string
    port         = number
  })

  default = {
    replicas     = 1
    storage_size = "4Gi"
    port         = 9000
  }
}
