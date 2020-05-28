variable "namespace" {
  description = "namespace to install stan"
  type        = string
  default     = "default"
}

variable "replicas" {
  description = "number of stan replicas"
  type        = number
  default     = 2
}

variable "cluster_id" {
  description = "stan clusterID"
  type        = string
  default     = "stan-cluster"
}

variable "store_type" {
  description = "stan data storage type: file or memory"
  type        = string
  default     = "memory"
}

variable "nats" {
  description = "nats server to use for the underlying nats connections: nats://nats:4222"
  type = object({
    host = string
    port = number
  })
}
