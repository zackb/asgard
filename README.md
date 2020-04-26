# Asgard
This is a terraform definition to install and manage Kubernetes on a cluster of Raspberry Pis. It also optionally installs some useful software.



### k3s
Uses the awesome [k3s](https://k3s.io) and [xunleii's](https://registry.terraform.io/modules/xunleii/k3s/module) great terraform module to install and manage Kubernetes


### Software
Optionally installs some software I like that also runs on the pi's arm7 chips

- Minio - s3 clone
- NATS - highly resilient and performant message passing system
- NATS Streaming - nats append-only-log style data streaming
- cert-manager - to handle SSL certificates using Let's Encrypt
- docker-registry - for a custom private docker image registry
- [wintermute](https://github.com/zackb/wintermute) - my toy project which uses most of the above (wintermute is the bad AI in the [Neuromancer](https://en.wikipedia.org/wiki/Neuromancer) book)

### Usage
See the [example tfvars file](iac/example.tfvars) but all that's needed is the pi's name, ip, and ssh private key location.

```
name = "asgard"
master = {
    name        = "odin"
    host        = "192.168.1.200"
    user        = "root"
    private_key = "~/.ssh/id_rsa"
}

nodes = {
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
    fenris = {
      name = "fenris"
      ip = "192.168.1.202"
      labels = {
        "node.kubernetes.io/pool" = "service-pool"
      }
      taints = {}
      connection = {
        type        = "ssh"
        host        = "192.168.1.202"
        user        = "root"
        private_key = "~/.ssh/id_rsa"
      }
    },
  }
}
```
