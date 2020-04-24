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
  type = map(object({
    name       = string
    ip         = string
    labels     = map(string)
    taints     = map(string)
    connection = map(any)
  }))
}
