#!/bin/bash

/sbin/tcpdump port 24001 or port 56956 or port 25001 -w /home/ec2-user/file_result.pcap &

sleep 300
pkill -9 tcpdump
aws s3 cp /home/ec2-user/file_result.pcap s3://gnome-hub.com/
rm -rf /home/ec2-user/file_result.pcap
