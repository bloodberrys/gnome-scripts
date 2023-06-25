#!/bin/bash

function select_proxy() {
  # File path containing the list of IP addresses and ports
  list_file="$(ls /tmp/proxy-.log | tail -n 1)"

  # Read the file into an array
  readarray -t ip_port_list < "$list_file"

  # Get the length of the array
  array_length=${#ip_port_list[@]}

  # Check if the array is empty
  if [ "$array_length" -eq 0 ]; then
    echo "No IP addresses and ports found in the list file."
    return 1
  fi

  # Select a random index from the array
  index=$((RANDOM % array_length))

  # Get the selected IP address and port
  selected_ip_port=${ip_port_list[$index]}

  # Output the selected IP address and port
  timestamp=$(date '+%Y-%m-%d %H:%M:%S %Z')
  echo -e "[$timestamp] $selected_ip_port" >> "/home/centos/selected_proxies"
  echo "$selected_ip_port"
}

run_process(){
    local _filename=$1
    local _timestamp=$2
    array_of_ip_count=$(cat /tmp/${_filename}.log | grep -Eo '^[0-9]+' | tr '\n' ' ')
    array_of_ip=$(cat /tmp/${_filename}.log | grep -Eo '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$' | tr '\n' ' ')

    IFS=" " read -r -a ipcounts <<< "$array_of_ip_count"
    IFS=" " read -r -a ips <<< "$array_of_ip"

    IFS=" " read -r -a whitelisted_ip <<< "114.124.144.26 49.144.38.198 114.142.173.62 120.28.216.173 52.219.128.250 52.219.132.90 52.219.36.66 45.202.25.237 52.219.32.246 52.219.132.186 52.219.124.50 49.144.43.24 112.215.245.216 112.215.200.69 110.54.184.23 175.176.20.22 120.28.216.28 175.176.32.24 46.146.160.25"

    dir="/tmp/ip_blocked"
    dir2="/tmp/iplist"

    if [[ ! -e $dir ]]; then
        sudo mkdir -p $dir
    elif [[ ! -d $dir ]]; then
        echo "$dir already exists but is not a directory" 1>&2
    fi
    if [[ ! -e $dir2 ]]; then
        sudo mkdir -p $dir2
    elif [[ ! -d $dir2 ]]; then
        echo "$dir2 already exists but is not a directory" 1>&2
    fi

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
        if [ ${ipcounts[$i]} -gt 9 ] && [ ${whitelist} -eq 0 ]; then
            
            # checking the ips
            sudo iptables -C INPUT -s ${ips[$i]} -j DROP

            # If the exit status is 1, meaning we need to execute the ips to ip tables
            if [ $? -eq 1 ]; then
                # save the ip to list with command
                echo "iptables -A INPUT -s ${ips[$i]} -j DROP" >> "/tmp/ip_blocked/ip_blocked_${_filename}.log"
                echo "${ips[$i]}" >> "/tmp/iplist/iplist_${_filename}.log"

                # execute the iptables block
                sudo iptables -A INPUT -s ${ips[$i]} -j DROP
                counter=$((counter+1))
            fi
        fi
    done

    if [ $counter -gt 0 ]; then
        # persistent save iptables
        service iptables save       
    else
        echo -e "ALL GOOD, no threat detected, ALL OK and nothing to do."
    fi

    # always execute the report each run_process call
    IP_IPLIST_LOG_FILENAME=$(find /tmp/iplist/ -type f -printf "%f\n" -mmin +1 | head -n 1)
    if [ -z "$IP_IPLIST_LOG_FILENAME" ]; then
        echo "ALL GOOD, no iplist file detected, nothing to do"
    else
        message=$(awk '{printf "%s<br>", $0}' "/tmp/iplist/${IP_IPLIST_LOG_FILENAME}")
        string="There are $counter IPs blocked:<br>$message"
        send_discord_security_report "$string" "$_timestamp"
    fi 
    counter=0

}

send_discord_security_report(){
    webhook_url=https://discord.com/api/webhooks/1122260171972952104/Pu8LhyV7Yf7G1q-KYzmcWLKhAzefcrCvz88R9XXiIlKMyDAc2BJmQl_s2BtR-KbZaAwJ
    local _message=$1
    local _timestamp=$2

    # count total files in a directory
    total_files=$(ls /tmp/ip_blocked/ | wc -l)
    total_files2=$(ls /tmp/iplist/ | wc -l)

    if [ ${total_files} -eq 0 ] && [ ${total_files2} -eq 0 ]; then
        echo "nothing to send as security notif"
    
    else
        IP_BLOCKED_TO_BE_SENT=$(find /tmp/ip_blocked/ -type f -printf "%f\n" -mmin +1 | head -n 1)
        IP_IPLIST_TO_BE_SENT=$(find /tmp/iplist/ -type f -printf "%f\n" -mmin +1 | head -n 1)

        prefix_1=/tmp/ip_blocked/
        prefix_2=/tmp/iplist/

        IP_BLOCKED=$(echo $prefix_1$IP_BLOCKED_TO_BE_SENT)
        IP_IPLIST=$(echo $prefix_2$IP_IPLIST_TO_BE_SENT)

        SUBJECT="⚠️ Security Report - $_timestamp ⚠️"
        CONTENT=$(echo $_message | sed 's3<br>3\n3g')
        size=${#CONTENT}
        if [[ $size -gt 2000 ]]; then
            CONTENT=${CONTENT:0:1500}
        fi

        proxy=$(select_proxy)
        payload_json=$(jq -n --arg content "$CONTENT" --arg subject "$SUBJECT" '{username: "Gnome-Security", content: "\( $subject )\n\n\( $content )"}')
        curl -g -F "payload_json=$payload_json" -F "file1=@$IP_BLOCKED" -F "file2=@$IP_IPLIST" -x "$proxy" "$webhook_url"

        sudo rm -rf $IP_BLOCKED
        sudo rm -rf $IP_IPLIST
    fi

}

send_discord_mt(){
    webhook_url=https://discord.com/api/webhooks/1122260171972952104/Pu8LhyV7Yf7G1q-KYzmcWLKhAzefcrCvz88R9XXiIlKMyDAc2BJmQl_s2BtR-KbZaAwJ
    local _message=$1
    local _timestamp=$2

    SUBJECT="⚠️ Maintenance Mode Report - $_timestamp ⚠️"
    CONTENT=$(echo $_message | sed 's3<br>3\n3g')
    size=${#CONTENT}
    if [[ $size -gt 2000 ]]; then
        CONTENT=${CONTENT:0:1500}
    fi

    proxy=$(select_proxy)
    payload_json=$(jq -n --arg content "$CONTENT" --arg subject "$SUBJECT" '{username: "Gnome-Security", content: "\( $subject )\n\n\( $content )"}')
    curl -g -F "payload_json=$payload_json" -x "$proxy" "$webhook_url"

}

MT_MODE=$(cat avalon_mt.state)

if [ "$MT_MODE" == "true" ]; then
    timestamp=$(date '+%Y-%m-%d_%H-%M-%S_%Z')
    echo "MT MODE"
    send_discord_mt "Maintenance mode activated, ddos blocker is off status" "$timestamp"
    exit 1
else
    echo -e "Maintenance mode is off.. ddos blocker is on"
fi

export TZ=Asia/Jakarta
timestamp=$(date '+%Y-%m-%d_%H-%M-%S_%Z')

echo -e "[TASK] Checking the netstat..."
netstat -npt | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr | grep -Eo '[0-9]+[ ]{1}[0-9.]+' | grep -vE '^[0-9]+[ ][1][0].[0].[0-9]{1,3}.[0-9]{1,3}$' | grep -vE '^[0-9]+[ ]127.0.0.1$' > "/tmp/ip_list_total_$timestamp.log"
netstat -npt | grep 13412 | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr | grep -Eo '[0-9]+[ ]{1}[0-9.]+' | grep -vE '^[0-9]+[ ][1][0].[0].[0-9]{1,3}.[0-9]{1,3}$' | grep -vE '^[0-9]+[ ]127.0.0.1$' > "/tmp/ip_13412_$timestamp.log"

echo -e "\n[PRE-TASK] Obtaining and processing the netstat result file from /tmp/ip_list_total.log and /tmp/ip_13412.log"
ipfiles="/tmp/ip_list_total_$timestamp.log" # WE CAN SIMPLY CHANGE THIS FOR DEBUGGING
if [ ! -f "$ipfiles" ]; then
    echo "✗ File ${ipfiles} not found on your machine!"
    echo "exitting..."
    exit 1
else
    echo "✓ File ${ipfiles} is found, continue to the next task..."
    ipfiles2="/tmp/ip_13412_$timestamp.log" # WE CAN SIMPLY CHANGE THIS FOR DEBUGGING
    if [ ! -f "$ipfiles2" ]; then
        echo "✗ File ${ipfiles2} not found on your machine!"
        echo "exitting..."
        exit 1
    else
        echo "✓ File ${ipfiles2} is found, continue to the next task..."
        run_process "ip_list_total_$timestamp" "$timestamp"
        run_process "ip_13412_$timestamp" "$timestamp"
    fi
fi



