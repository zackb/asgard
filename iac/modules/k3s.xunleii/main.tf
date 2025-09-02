terraform {
  required_version = ">= 0.12, < 2.0.0"
  required_providers {
    http       = "~> 1.1"
    local      = "~> 1.4"
    null       = "~> 2.1"
    random     = "~> 2.2"
    template   = "~> 2.1"
  }
}

resource "random_password" "k3s_cluster_secret" {
  length  = 48
  special = false
}
