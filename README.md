# Instalação de servidores TDP - DevOps

O objetivo deste repositório é automatizar o provisionamento de máquinas para a stack TDP de dados da Tecnisys.


# Pré-requisitos

1. Configurar conta AWS
2. Credenciais AWS (role Admin)
3. Configurar variáveis de ambiente de credenciais AWS
4. Configurar private key - EC2

```
export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
``` 
4. Identificar o vpc id e subnet id correspondente a sua infraestrutura.
5. Criar uma key de acesso aos servidores - ver mais em: 

# Como executar os scripts

1. Executar scripts terraform

```
cd terraform-aws
terraform init
terraform apply -var 'key_name=keypair-tdp.pem'
```

2. Executar script para geracao de inventario ansible

../scripts/gen-inventory-hosts-public.sh 

2. Executar ansible
cd ansible

ansible-playbook playbook-master.yml -e "repo_username=usuariotdp repo_password=teste123"

ansible-playbook playbook-master.yml -i inventory.ini -e @vars.yaml