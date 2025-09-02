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

