.PHONY: all

init:   
		terraform init $(TFVARS)
plan: init
		terraform plan $(TFVARS)
apply: init
		terraform apply $(TFVARS)
destroy: destroy
		terraform destroy $(TFVARS)