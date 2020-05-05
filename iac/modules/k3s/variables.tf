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
