#!/bin/bash

read -p "Enter website: " site

if [ -n "$site" ]; then
    nslookup "$site" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v "127.0.0.53" | tee iplist.txt
else
    echo "Enter a valid website."
    exit 1
fi

ip_list="iplist.txt"
chain="INPUT"
action="DROP"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root: sudo $0" >&2
    exit 1
fi

# Check if the IP list exists and is not empty
if [ ! -s "$ip_list" ]; then
    echo "No valid IPs found in $ip_list. Exiting." >&2
    exit 1
fi

while read -r ip; do
    echo "Blocking $ip..."
    iptables -A "$chain" -s "$ip" -j "$action"
done < "$ip_list"

echo "Done!"
