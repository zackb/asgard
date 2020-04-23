output "kubeconfig" {
  # TODO: value = data.external.kubeconfig.result["kubeconfig"]
  value = "kubeconfig.yaml"
}
