variable "k3s_version" {
  description = "the version of k3s to install/upgrade"
  type        = string
}

variable "master" {
  description = "master node configuration"
  type = object({
    name        = string
    host        = string
    user        = string
    private_key = string
  })
}

variable "nodes" {
  description = "worker node configuration"
  type = list(object({
    name        = string
    host        = string
    user        = string
    private_key = string
  }))
}
