variable "release_name" {
  description = "Helm release name"
  type        = string
  default     = "minio"
}

variable "namespace" {
  description = "Kubernetes namespace to install into"
  type        = string
  default     = "default"
}

variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
  default     = false
}

variable "chart_repository" {
  description = "MinIO Helm chart repository"
  type        = string
  default     = "https://charts.min.io/"
}

variable "chart_version" {
  description = "Chart version (leave null for latest)"
  type        = string
  default     = null
}

variable "image_tag" {
  description = "Optional image tag for MinIO"
  type        = string
  default     = "RELEASE.2024-12-18T13-15-44Z"
}

variable "mode" {
  description = "MinIO mode: standalone or distributed"
  type        = string
  default     = "distributed"
  validation {
    condition     = contains(["standalone", "distributed"], var.mode)
    error_message = "mode must be 'standalone' or 'distributed'."
  }
}

variable "replicas" {
  description = "Number of replicas (1 for standalone; >=4 and even for distributed)"
  type        = number
  default     = 1
}

variable "storage_size" {
  description = "PVC size for data"
  type        = string
  default     = "100Gi"
}

variable "storage_class" {
  description = "StorageClass name (null to use default)"
  type        = string
  default     = null
}

variable "service_type" {
  description = "Service type: ClusterIP, NodePort, or LoadBalancer"
  type        = string
  default     = "ClusterIP"
  validation {
    condition     = contains(["ClusterIP", "NodePort", "LoadBalancer"], var.service_type)
    error_message = "service_type must be ClusterIP, NodePort, or LoadBalancer."
  }
}

variable "nodeport_api" {
  description = "NodePort for API (9000) when service_type=NodePort"
  type        = number
  default     = null
}

variable "nodeport_console" {
  description = "NodePort for Console (9001) when service_type=NodePort"
  type        = number
  default     = null
}

variable "node_selector" {
  description = "nodeSelector map for scheduling"
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Pod tolerations"
  type        = list(any)
  default     = []
}

variable "affinity" {
  description = "Pod affinity rules"
  type        = any
  default     = null
}

variable "resources" {
  description = "Kubernetes resource requests/limits"
  type = object({
    limits = optional(map(string))
    requests = optional(map(string))
  })
  default = {
    limits = {
      cpu    = "1000m"
      memory = "1Gi"
    }
    requests = {
      cpu    = "250m"
      memory = "256Mi"
    }
  }
}

variable "existing_secret_name" {
  description = "Use an existing secret with keys: rootUser, rootPassword"
  type        = string
  default     = null
}

variable "root_user" {
  description = "Override root user (if not using existing_secret_name)"
  type        = string
  default     = null
  sensitive   = true
}

variable "root_password" {
  description = "Override root password (if not using existing_secret_name)"
  type        = string
  default     = null
  sensitive   = true
}

variable "ingress" {
  type = object({
    enabled          = bool
    ingressClassName = optional(string, "")
    annotations      = optional(map(string), {})
    hosts            = optional(list(string), [])
    tls              = optional(list(object({
      secretName = string
      hosts      = list(string)
    })), [])
  })
  default = {
    enabled = false
  }
}
