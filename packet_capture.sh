#!/bin/bash

nohup tcpdump port 24001 or port 56956 or port 25001 -w /tmp/file_result.pcap &

sleep 1800
pkill -9 tcpdump
aws s3 cp /tmp/file_result.pcap s3://gnome-hub.com/
rm -rf /tmp/file_result.pcap
