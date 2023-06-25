#!/bin/bash

proxy_list=$(curl -s https://spys.me/proxy.txt)

# Extract IP addresses and ports using awk
timestamp=$(date '+%Y-%m-%d %H:%M:%S %Z')
echo "$proxy_list" | awk '{split($0, a, " "); for (i=1; i<=length(a); i++) if (a[i] ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$/) print a[i]}' > "/tmp/proxy-.log"