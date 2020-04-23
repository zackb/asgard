output "access_key" {
  value = random_string.minio-access-key.result
}

output "secret_key" {
  value = random_string.minio-secret-key.result
}

output "endpoint" {
  value = join(":", [helm_release.minio.name, var.config.port])
}
