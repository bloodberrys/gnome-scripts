#!/bin/bash

# run with cron
run_process(){
    local _timestamp=$1

    filename=$(ls -U /var/www/html/suspected_ip/ | grep 'suspicious_layer7_')

    IFS=" " read -r -a array_filename <<< "$filename"

    filenamecount=${#array_filename[@]}

    for((i=0; i<filenamecount; i++))
    do 
        ipcount=$(< "/var/www/html/suspected_ip/${array_filename[$i]}" awk '{a[$1]++} END {for(i in a) print a[i],i}' | sort -nr | grep -Eo '^[0-9]')

        if [ ${ipcount} -gt 4 ]; then
            # get ip from filename
            ipaddress=$(echo ${array_filename[$i]} | grep -Eo '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$')

            # checking the ips
            sudo iptables -C INPUT -s ${ipaddress} -j DROP

            # If the exit status is 1, meaning we need to execute the ips to ip tables
            if [ $? -eq 1 ]; then

                echo -e "[IP-DROPPER]\niptables -A INPUT -s ${ipaddress} -j DROP" >> "/tmp/ip_blocked_${ipaddress}.log"
                echo -e "\n\n[ACTION] EXECUTE THIS DELETE STATEMENT\nDELETE a,b FROM account_details a JOIN account b ON b.id = a.account_id WHERE a.ip_address LIKE '%${ipaddress}%' AND a.is_verified = 0" >> "/tmp/ip_blocked_${ipaddress}.log"
                
                sample_log=$(tail /var/log/httpd/access_log | grep ${ipaddress})
                echo -e "\n\n[SAMPLE HTTP LOGS]\n$sample_log" >> "/tmp/ip_blocked_${ipaddress}.log"
                
                # Drop and save
                sudo iptables -A INPUT -s ${ipaddress} -j DROP
                service iptables save

                # Send discord we have blocked it
                # Also send how to clean the database.
                string="Layer 7 IP blocked:<br>\`$ipaddress\`<br>"
                filename="/tmp/ip_blocked_${ipaddress}.log"
                send_discord_security_report "$string" "$filename" "$_timestamp"
                
                # delete the file
                rm -f "/var/www/html/suspected_ip/${array_filename[$i]}"
            fi
        fi
        echo "no threat, skipping..."
    done

}

send_discord_security_report(){
    webhook_url=https://discord.com/api/webhooks/1002015434532466779/UqyXpNSrj28Jop_77beQeSJ2tn9nd-I-vlMM1GzHPeFRklu-Sdw--tNXbtmRsu5u67bu
    local _message=$1
    local _filename=$2
    local _timestamp=$3
    SUBJECT="⚠️ Security Report (Layer 7) - $_timestamp ⚠️"
    CONTENT=$(echo $_message | sed 's3<br>3\n3g')
    size=${#CONTENT}
    if [[ $size -gt 2000 ]]; then
        CONTENT=${CONTENT:0:1500}
    fi
    payload_json=$(jq -n --arg content "$CONTENT" --arg subject "$SUBJECT" '{username: "Layer 7 Security", content: "\( $subject )\n\n\( $content )"}')
    curl -g -F "payload_json=$payload_json" -F "file1=@$_filename" "$webhook_url"
}

export TZ=Asia/Jakarta
timestamp=$(date '+%Y-%m-%d_%H-%M-%S_%Z')

run_process "$timestamp"


