#!/bin/bash

# Recuperar os IPs publicos das instâncias Master e Data
master_ips=$(terraform output -json master_public_ips | jq -r '.[]')
data_ips=$(terraform output -json data_public_ips | jq -r '.[]')

# Gerar o arquivo inventory.ini
echo "[master]" > inventory.ini
for ip in $master_ips; do
  echo "master ansible_host=$ip ansible_user=centos ansible_ssh_private_key_file=../keypair-tdp.pem" >> inventory.ini
done

echo "[data]" >> inventory.ini
for ip in $data_ips; do
  echo "data ansible_host=$ip ansible_user=centos ansible_ssh_private_key_file=../keypair-tdp.pem" >> inventory.ini
done

# Gerar o arquivo hosts
echo "127.0.0.1 localhost" > hosts
count=1
for ip in $master_ips; do
  echo "$ip master$count.markway.com.br master$count" >> hosts
  count=$((count + 1))
done

count=1
for ip in $data_ips; do
  echo "$ip data$count.markway.com.br data$count" >> hosts
  count=$((count + 1))
done

# Exibir os arquivos gerados
echo "Arquivo inventory.ini:"
cat inventory.ini
echo
echo "Arquivo hosts:"
cat hosts

# Instruções adicionais, se necessário
echo "Os arquivos 'inventory.ini' e 'hosts' foram gerados."
cp hosts inventory.ini ./ansible
echo "Os arquivos 'inventory.ini' e 'hosts' foram copiados para o diretório ansible."
echo "Transfira os arquivos para a instância Bastion usando SCP."
