default: help

help:
	@echo "Makefile commands:"
	@echo "  init        - Initialize Terraform"
	@echo "  plan        - Create and show an execution plan"
	@echo "  apply       - Apply the changes required to reach the desired state of the configuration"

apply:
	terraform apply -var-file="asgard.tfvars"

apply-k8s:
	terraform apply -target=module.k3s -var-file="asgard.tfvars"

cert-manager:
	 terraform apply -var-file="asgard.tfvars" -target=module.cert-manager.helm_release.cert_manager

docker-login:
	docker login registry.bartel.com -u admin -p $(terraform output -raw registry_password)
