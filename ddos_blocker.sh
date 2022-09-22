#!/bin/bash

run_process(){
    local _filename=$1
    local _timestamp=$2
    array_of_ip_count=$(cat /tmp/${_filename}.log | grep -Eo '^[0-9]+' | tr '\n' ' ')
    array_of_ip=$(cat /tmp/${_filename}.log | grep -Eo '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$' | tr '\n' ' ')

    IFS=" " read -r -a ipcounts <<< "$array_of_ip_count"
    IFS=" " read -r -a ips <<< "$array_of_ip"

    IFS=" " read -r -a whitelisted_ip <<< "175.176.20.22 120.28.216.28 175.176.32.24 46.146.160.25"

    iplength=${#ips[@]}
    counter=0
    for((i=0; i<iplength; i++))
    do  
        whitelist=0
        # whitelist check
        if [[ " ${whitelisted_ip[*]} " =~ " ${ips[$i]} " ]]; then
            # whatever you want to do when array contains value
            whitelist=1
        fi

        # check the ip count that more than 7
        if [ ${ipcounts[$i]} -gt 5 ] && [ ${whitelist} -eq 0 ]; then
            
            # checking the ips
            sudo iptables -C INPUT -s ${ips[$i]} -j DROP

            # If the exit status is 1, meaning we need to execute the ips to ip tables
            if [ $? -eq 1 ]; then
                # save the ip to list with command
                echo "iptables -A INPUT -s ${ips[$i]} -j DROP" >> "/tmp/ip_blocked_${_filename}.log"
                echo "${ips[$i]}" >> "/tmp/iplist_${_filename}.log"

                # execute the iptables block
                sudo iptables -A INPUT -s ${ips[$i]} -j DROP
                counter=$((counter+1))
            fi
        fi
    done

    if [ $counter -gt 0 ]; then
        service iptables save
        message=$(awk '{printf "%s<br>", $0}' "/tmp/iplist_${_filename}.log")
        string="There are $counter IPs blocked:<br>$message"
        filename="/tmp/ip_blocked_${_filename}.log"
        iplistfile="/tmp/${_filename}.log"
        send_discord_security_report "$string" "$filename" "$iplistfile" "$_timestamp"
        
    else
        echo -e "ALL GOOD, ALL OK and nothing to do."
    fi

    counter=0

}

send_discord_security_report(){
    webhook_url=https://discord.com/api/webhooks/1002015434532466779/UqyXpNSrj28Jop_77beQeSJ2tn9nd-I-vlMM1GzHPeFRklu-Sdw--tNXbtmRsu5u67bu
    local _message=$1
    local _filename=$2
    local _iplistfile=$3
    local _timestamp=$4
    SUBJECT="⚠️ Security Report - $_timestamp ⚠️"
    CONTENT=$(echo $_message | sed 's3<br>3\n3g')
    size=${#CONTENT}
    if [[ $size -gt 2000 ]]; then
        CONTENT=${CONTENT:0:1500}
    fi
    payload_json=$(jq -n --arg content "$CONTENT" --arg subject "$SUBJECT" '{username: "Gnome-Security", content: "\( $subject )\n\n\( $content )"}')
    curl -g -F "payload_json=$payload_json" -F "file1=@$_filename" -F "file2=@$_iplistfile" "$webhook_url"
}

export TZ=Asia/Jakarta
timestamp=$(date '+%Y-%m-%d_%H-%M-%S_%Z')

echo -e "[TASK] Checking the netstat..."
netstat -npt | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr | grep -Eo '[0-9]+[ ]{1}[0-9.]+' | grep -vE '^[0-9]+[ ][1][0].[0].[0-9]{1,3}.[0-9]{1,3}$' | grep -vE '^[0-9]+[ ]127.0.0.1$' > "/tmp/ip_list_total_$timestamp.log"
netstat -npt | grep 56956 | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr | grep -Eo '[0-9]+[ ]{1}[0-9.]+' | grep -vE '^[0-9]+[ ][1][0].[0].[0-9]{1,3}.[0-9]{1,3}$' | grep -vE '^[0-9]+[ ]127.0.0.1$' > "/tmp/ip_56956_$timestamp.log"

echo -e "\n[PRE-TASK] Obtaining and processing the netstat result file from /tmp/ip_list_total.log and /tmp/ip_56956.log"
ipfiles="/tmp/ip_list_total_$timestamp.log" # WE CAN SIMPLY CHANGE THIS FOR DEBUGGING
if [ ! -f "$ipfiles" ]; then
    echo "✗ File ${ipfiles} not found on your machine!"
    echo "exitting..."
    exit 1
else
    echo "✓ File ${ipfiles} is found, continue to the next task..."
    ipfiles2="/tmp/ip_56956_$timestamp.log" # WE CAN SIMPLY CHANGE THIS FOR DEBUGGING
    if [ ! -f "$ipfiles2" ]; then
        echo "✗ File ${ipfiles2} not found on your machine!"
        echo "exitting..."
        exit 1
    else
        echo "✓ File ${ipfiles2} is found, continue to the next task..."
        run_process "ip_list_total_$timestamp" "$timestamp"
        run_process "ip_56956_$timestamp" "$timestamp"
    fi
fi



