output "namespace" {
  value = var.namespace
}

output "endpoint" {
  description = "MinIO S3 API endpoint"
  value       = var.ingress.enabled ? "${var.ingress.hostname}" : "${var.release_name}.${var.namespace}.svc.cluster.local:9000"
}

output "secret_name" {
  value = var.existing_secret_name != null ? var.existing_secret_name : kubernetes_secret.creds[0].metadata[0].name
}

output "root_user" {
  description = "Root user (if auto-generated)"
  value       = var.root_user != null ? var.root_user : (var.existing_secret_name == null ? nonsensitive(random_password.root_user.result) : null)
  sensitive   = true
}

output "root_password" {
  description = "Root password (if auto-generated)"
  value       = var.root_password != null ? var.root_password : (var.existing_secret_name == null ? random_password.root_password.result : null)
  sensitive   = true
}

output "helm_release_name" {
  value = helm_release.minio.name
}

output "notes" {
  description = "Helpful commands"
  value = <<EOT
To port-forward locally:
  kubectl -n ${var.namespace} port-forward svc/${var.release_name} 9000:9000 9001:9001

Then open:
  Console: http://localhost:9001
  S3 API: http://localhost:9000

Fetch credentials (if module created them):
  kubectl -n ${var.namespace} get secret ${var.existing_secret_name != null ? var.existing_secret_name : "${var.release_name}-creds"} -o jsonpath='{.data.rootUser}' | base64 -d; echo
  kubectl -n ${var.namespace} get secret ${var.existing_secret_name != null ? var.existing_secret_name : "${var.release_name}-creds"} -o jsonpath='{.data.rootPassword}' | base64 -d; echo
EOT
}

