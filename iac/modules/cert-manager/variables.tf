variable "kubeconfig" {
  description = "kubeconfig yaml"
  type        = string
}

variable "namespace" {
  description = "namespace to install cert-manager"
  type        = string
}
