output "host" {
  value = helm_release.nats.name
}

output "port" {
  value = 6222
}
