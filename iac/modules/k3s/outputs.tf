output "kubeconfig" {
  depends_on = [null_resource.kubeconfig]
  # TODO: value = data.external.kubeconfig.result.kubeconfig
  value = "kubeconfig.yaml"
}
