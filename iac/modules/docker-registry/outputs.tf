output "registry_username" {
  value = "admin"
}

output "registry_password" {
  value     = random_password.registry_password.result
  sensitive = true
}
