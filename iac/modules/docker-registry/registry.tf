resource "helm_release" "docker_registry" {
  chart     = "stable/docker-registry"
  name      = "docker-registry"
  namespace = "kube-system"

  set {
    name = "ingress.enabled"
    value = true
  }

  dynamic "set" {
    for_each = ["docker.jeedup.net"]
    content {
      name  = join("", ["ingress.hosts[", set.key, "]"])
      value = set.value
    }
  }
}
