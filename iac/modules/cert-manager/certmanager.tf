data "helm_repository" "stable" {
  name     = "jetstack"
  url      = "https://charts.jetstack.io"
}

resource "helm_release" "cert-manager" {
  name      = "cert-manager"
  namespace = var.namespace
  chart     = "jetstack/cert-manager"
  version   = "v0.14.2"

  depends_on = [null_resource.certmanager_prerequisites]
}
resource "null_resource" "certmanager_prerequisites" {
  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig ${var.kubeconfig} --namespace ${var.namespace} -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml"
  }
  provisioner "local-exec" {
    when    = "destroy"
    command = "kubectl delete --kubeconfig ${var.kubeconfig} --namespace ${var.namespace} -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml"
  }
}
