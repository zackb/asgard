output "cluster_id" {
  value = var.cluster_id
}

output "host" {
  value = helm_release.nats-streaming.name
}
