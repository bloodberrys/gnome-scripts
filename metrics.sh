#!/bin/bash

send_discord_server_up(){
    webhook_url=https://discord.com/api/webhooks/1020297971692208138/c9QC3fj4dzHycEAd84QMs-dF-MQp_97y0U3cPn7EIrv3v_yOvMLh46IqcROtxmIAFHiv
    SUBJECT="CPU and RAM status"
    local _message=$1
    CONTENT=$(echo $_message | sed 's3<br>3\n3g')
    netstat -s > /tmp/tcpudp.log
    netstat -npt | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr > /tmp/tcp_by_ip_count.log
    netstat -npt | grep 56956 | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr > /tmp/tcp_56956.log
    netstat -npt | grep 25001 | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr > /tmp/tcp_25001.log
    netstat -npt | grep 24001 | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr > /tmp/tcp_24001.log
    netstat -npt | awk '{print $6}' | sort | uniq -c | sort -nr > /tmp/synflooddetection.log
    netstat -npt | grep SYN_RECV | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr > /tmp/singe_ip_attack.log
    netstat -npt  | grep SYN_RECV | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr > /tmp/multiple_ip_attack.log
    size=${#CONTENT}
    payload_json=$(jq -n --arg content "$CONTENT" --arg subject "$SUBJECT" '{username: "Gnome-Automation", content: "\( $subject )\n\n\( $content )"}')
    curl -g -F "payload_json=$payload_json" -F "file1=@/tmp/tcpudp.log" -F "file2=@/tmp/tcp_by_ip_count.log" -F "file3=@/tmp/tcp_56956.log" -F "file4=@/tmp/tcp_24001.log" -F "file5=@/tmp/tcp_25001.log" -F "file6=@/tmp/synflooddetection.log" -F "file7=@/tmp/singe_ip_attack.log" -F "file8=@/tmp/multiple_ip_attack.log" "$webhook_url"
}