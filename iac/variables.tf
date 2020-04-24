variable "name" {
  type        = string
  description = "name of the kubernetes cluster"
  default     = "asgard"
}

variable "master" {
  description = "host to use for kubernetes master"
  type = object({
    name        = string
    host        = string
    user        = string
    private_key = string
  })

  default = {
    name        = "odin"
    host        = "192.168.1.200"
    user        = "root"
    private_key = "~/.ssh/id_rsa"
  }
}

variable "nodes" {
  description = "hosts to use for kubernetes worker nodes"
  type = map(object({
    name       = string
    ip         = string
    labels     = map(string)
    taints     = map(string)
    connection = map(any)
  }))
  default = {}
  /*
  default = {
    thor = {
      name = "thor"
      ip = "192.168.1.201"
      labels = {
        "node.kubernetes.io/pool" = "service-pool"
      }
      taints = {}
      connection = {
        type        = "ssh"
        host        = "192.168.1.201"
        user        = "root"
        private_key = "~/.ssh/id_rsa"
      }
    },
  }
  */
}
