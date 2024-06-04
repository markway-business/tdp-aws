#!/bin/bash

# Arquivo de inventário do Ansible
INVENTORY_FILE="ansible_inventory"

# Limpar o arquivo de inventário existente
> $INVENTORY_FILE

# Adicionar hosts master
echo "[master]" >> $INVENTORY_FILE
for ip in $1; do
  echo "$ip" >> $INVENTORY_FILE
done

# Adicionar hosts data
echo "[data]" >> $INVENTORY_FILE
for ip in $2; do
  echo "$ip" >> $INVENTORY_FILE
done