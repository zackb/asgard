module "k3s" {
  source  = "xunleii/k3s/module"
  version = "1.7.0"

  server_node = {
    name = var.master.name
    ip   = var.master.host

    labels = {
      "node.kubernetes.io/type" = "master"
    }

    taints = {
      # "node.k3s.io/type" = "server:NoSchedule"
    }

    connection = {
      type        = "ssh"
      host        = var.master.host
      user        = var.master.user
      private_key = file(var.master.private_key)
    }
  }

  // TODO!
  agent_nodes = var.nodes
}

resource null_resource kubeconfig {
  depends_on = [module.k3s]

  provisioner "local-exec" {
    command = "scp ${var.master.user}@${var.master.host}:/etc/rancher/k3s/k3s.yaml kubeconfig && kubectl config view --raw | sed -E s/127.0.0.1/${var.master.host}/g > kubeconfig.yaml && rm kubeconfig"
    environment = {
      KUBECONFIG = "kubeconfig"
    }
  }
}

data "external" "kubeconfig" {
  depends_on = [null_resource.kubeconfig]

  program = ["/bin/bash", "-c", "echo \"{\\\"kubeconfig\\\":\\\"kubeconfig.yaml\\\"}\""]
}
