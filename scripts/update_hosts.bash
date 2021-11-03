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
  cmd=$(printf "sudo -E -- sed -i.bkup -e s/%s/%s/ /etc/hosts" $old_ip $ip)
  echo $cmd
  if $cmd; then
    echo "$host entry in /etc/hosts updated successfully"
  else
    echo "/etc/hosts update failed for $host"
  fi
else
  echo "WARNING: hostname '$host' not found in /etc/hosts"
  echo "Create a hosts entry with the following command (requires root):"
  echo "echo '$ip     $host' >> /etc/hosts"
fi
