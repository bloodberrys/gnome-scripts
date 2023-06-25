#!/bin/bash

# IP address to check and delete
ip_address="$1"

# Check if the IP address is present in iptables
if iptables -S | grep -q "$ip_address"; then
  # Delete the IP address from iptables
  iptables -D INPUT -s "$ip_address/32" -j ACCEPT
  echo "[BLOCKED IP FOUND] IP address $ip_address deleted from iptables."
  echo $ip_address >> avalon_whitelisted_ips.txt
  service iptables save
else
  echo "IP address $ip_address not found in iptables."
fi