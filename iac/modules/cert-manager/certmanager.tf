locals {
  issuer = "letsencrypt"
  server = var.lets_encrypt_prod ? "https://acme-v02.api.letsencrypt.org/directory" : "https://acme-staging-v02.api.letsencrypt.org/directory"
}

data "helm_repository" "stable" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

resource "helm_release" "cert-manager" {
  # TODO: count = var.tls_enabled ? 1 : 0
  name      = "cert-manager"
  namespace = kubernetes_namespace.cert-manager.metadata.0.name
  chart     = "jetstack/cert-manager"
  version   = "v0.14.3.0"

  depends_on = [null_resource.certmanager_prerequisites]
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "null_resource" "certmanager_prerequisites" {
  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig ${var.kubeconfig} --namespace ${kubernetes_namespace.cert-manager.metadata.0.name} -f https://github.com/jetstack/cert-manager/releases/download/v0.14.3/cert-manager.crds.yaml"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete --kubeconfig ${var.kubeconfig} --namespace ${kubernetes_namespace.cert-manager.metadata.0.name} -f https://github.com/jetstack/cert-manager/releases/download/v0.14.3/cert-manager.crds.yaml"
  }
}
resource "null_resource" "certmanager_issuer" {
  triggers = {
    contents = data.template_file.certmanager_issuer.rendered
  }

  provisioner "local-exec" {
    command = <<EOT
      cat <<EOF | kubectl apply --kubeconfig ${var.kubeconfig} -f -
${data.template_file.certmanager_issuer.rendered}
EOF
EOT
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      cat <<EOF | kubectl delete --kubeconfig ${var.kubeconfig} -f -
${data.template_file.certmanager_issuer.rendered}
EOF
EOT
  }

  depends_on = [helm_release.cert-manager]
}

# TODO: delete secrets that were created?
resource "null_resource" "certificate" {
  count = length(var.certificates)

  triggers = {
    contents = data.template_file.certificate[count.index].rendered
  }

  provisioner "local-exec" {
    command = <<EOT
      cat <<EOF | kubectl apply --kubeconfig ${var.kubeconfig} -f -
${data.template_file.certificate[count.index].rendered}
EOF
EOT
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      cat <<EOF | kubectl delete --kubeconfig ${var.kubeconfig} -f -
${data.template_file.certificate[count.index].rendered}
EOF
EOT
  }

  depends_on = [helm_release.cert-manager]
}

data "template_file" "certmanager_issuer" {
  template = file("${path.module}/cluster-issuer.yml")

  vars = {
    name          = local.issuer
    namespace     = kubernetes_namespace.cert-manager.metadata.0.name
    email_address = var.email_address
    server        = local.server
  }
}

data "template_file" "certificate" {
  count = length(var.certificates)

  template = file("${path.module}/certificate.yml")

  vars = {
    issuer    = local.issuer
    namespace = var.certificates[count.index].namespace
    domain    = var.certificates[count.index].domain
  }
}
