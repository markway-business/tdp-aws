#/bin/bash
terraform init
terraform plan -var 'key_name=keypair-tdp'
terraform apply -var 'key_name=keypair-tdp'