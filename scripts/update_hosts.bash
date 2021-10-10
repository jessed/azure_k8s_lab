#! /bin/bash

if [[ -z $1 || -z $2 ]]; then
  echo "USAGE $0 <hostname> <ip>"
  return
else
  host=$1
  ip=$2
fi

if [[ ! -f $HOME/.hosts ]]; then exit 0; fi

old_ip=$(awk -v host=$host '$0 ~ host {print $1}' /etc/hosts)

if [[ -n $old_ip ]]; then
  echo sudo -E -- sed -i '' s/$old_ip/$ip/ /etc/hosts
  sudo -E -- sed -i '' s/$old_ip/$ip/ /etc/hosts
else
  echo "WARNING: hostname '$host' not found in /etc/hosts"
  echo "Create a hosts entry with the following command (requires root):"
  echo "echo '$ip     $host' >> /etc/hosts"
fi
