#! /bin/bash

resourceGroup="jessed-att-mvm-rg"
instances=$(az vmss list-instance-public-ips -g $resourceGroup -n mvmltm | jq -r .[].ipAddress)

hosts=""
count=0
for ip in $instances; do
  host="mvmltm0${count}"
  hosts="$hosts $host"
  old_ip=$(awk -v host=$host '$0 ~ host {print $1}' /etc/hosts)
  echo "sudo -E -- sed -i  s/$old_ip/$ip/ /etc/hosts  #($host)"
  sudo -E -- sed -i  '' s/$old_ip/$ip/ /etc/hosts
  ((count++))
done

echo ""

# print string to set environment on vmss hosts
for h in $hosts; do echo "cloud_env $h azure"; done

