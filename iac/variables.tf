variable "name" {
  description = "name of the kubernetes cluster"
  type        = string
  default     = "asgard"
}

variable "zone" {
  description = "domain name zone"
  type        = string
  default     = "jeedup.net"
}
variable "email_address" {
  description = "email address to use for Let's Encrypt"
  type        = string
  default     = "zack@bartel.com"
}

variable "tls_enabled" {
  description = "enabled tls for ingress and install letsencrypt"
  type        = bool
  default     = true
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
  type = list(object({
    name        = string
    host        = string
    user        = string
    private_key = string
  }))

  default = [
    {
      name        = "thor"
      host        = "192.168.1.201"
      user        = "root"
      private_key = "~/.ssh/id_rsa"
    },
    {
      name        = "fenris"
      host        = "192.168.1.202"
      user        = "root"
      private_key = "~/.ssh/id_rsa"
    }
  ]
}
