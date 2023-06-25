#!/bin/bash

function select_proxy() {
  # File path containing the list of IP addresses and ports
  list_file="ls /tmp/proxy-.log | tail -n 1 "

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
  echo "$selected_ip_port"
}

get_log(){
	local _server=$1
    local _base_dir_log=/data/s1001/bin/log

    echo "$_server"

    # get recent log file
    go=$(ls ${_base_dir_log} -tr | grep -E "${_server}[-_0-9\.log]+$" | tail -n 1)
    local _recent_log_file=$go

    logs=$(tail -n 100 $_base_dir_log/$_recent_log_file)

    echo $logs
}

send_mail(){
    domain=verification.gnome-hub.com
    api_key=--
    subject="[AVALON] Server Healthcheck Down Detected"
    local _message=$1
    to="alfianvansykes@gmail.com"
    from='Gnome Automation <automation@verification.gnome-hub.com>'
    url="https://api.mailgun.net/v3/$domain/messages"
    req="curl -g --user 'api:${api_key}' '$url' -F from='${from}' -F to='${to}' -F subject='${subject}' -F html=\"${message}\""
    eval "$req"
}

send_discord(){
    webhook_url=https://discord.com/api/webhooks/1122257679704932492/jRwpX8c9pHCbEtdDoNq2UnVE-BBf0Das7Pz0zP_3NQP8tTjYPbrYyVLN2gfvW_ouaKw-
    SUBJECT="!!![AVALON] Server Healthcheck: Down Detected!!!"
    local _message=$1
    ADMIN_ROLE="<@&983558291261112370>"
    BOOSTER_ROLE="<@&983549809409552445>"
    CONTENT=$(echo $message | sed 's3<br>3\n3g')
    size=${#CONTENT}
    echo -e "$CONTENT" > /tmp/discordmsg.log
    if [[ $size -gt 2000 ]]; then
        CONTENT=${CONTENT:0:1500}
    fi

    proxy=$(select_proxy)
    payload_json=$(jq -n --arg content "$CONTENT" --arg subject "$SUBJECT" --arg ar "$ADMIN_ROLE" --arg br "$BOOSTER_ROLE" '{username: "Avalon-Automation", content: "\( $subject )\nCC: \( $br ) \( $ar )\n\n\( $content )"}')
    curl -g -F "payload_json=$payload_json" -F "file1=@/tmp/discordmsg.log" -x "$proxy" "$webhook_url"
}

send_discord_server_up(){
    webhook_url=https://discord.com/api/webhooks/1122257679704932492/jRwpX8c9pHCbEtdDoNq2UnVE-BBf0Das7Pz0zP_3NQP8tTjYPbrYyVLN2gfvW_ouaKw-
    SUBJECT="[AVALON] Server Online Status"
    local _message=$1
    CONTENT=$(echo $_message | sed 's3<br>3\n3g')
    netstat -s > /tmp/tcpudp.log
    netstat -npt | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr > /tmp/tcp_by_ip_count.log
    netstat -npt | grep 13412 | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr > /tmp/tcp_13412.log
    netstat -npt | grep 25001 | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr > /tmp/tcp_25001.log
    netstat -npt | grep 24001 | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr > /tmp/tcp_24001.log
    netstat -npt | awk '{print $6}' | sort | uniq -c | sort -nr > /tmp/synflooddetection.log
    netstat -npt | grep SYN_RECV | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr > /tmp/singe_ip_attack.log
    netstat -npt  | grep SYN_RECV | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr > /tmp/multiple_ip_attack.log
    size=${#CONTENT}

    proxy=$(select_proxy)
    payload_json=$(jq -n --arg content "$CONTENT" --arg subject "$SUBJECT" '{username: "Gnome-Automation", content: "\( $subject )\n\n\( $content )"}')
    curl -g -F "payload_json=$payload_json" -F "file1=@/tmp/tcpudp.log" -F "file2=@/tmp/tcp_by_ip_count.log" -F "file3=@/tmp/tcp_13412.log" -F "file4=@/tmp/tcp_24001.log" -F "file5=@/tmp/tcp_25001.log" -F "file6=@/tmp/synflooddetection.log" -F "file7=@/tmp/singe_ip_attack.log" -F "file8=@/tmp/multiple_ip_attack.log" -x "$proxy" "$webhook_url"
}

lcomma() { 
    sed '$x;$G;/\(.*\),/!H;//!{$!d};$!x;$s//\1/;s/^\n//'
}

check_counter() {
    FILE=/tmp/counter_dn/counter
    if test -f "$FILE"; then
        string=$(cat /tmp/counter_dn/counter)
        size=${#string}
        if [ ${size} -gt 2 ]; then
            echo "already 3 times, skipping..."
            deletefile=$(find /tmp/counter_dn/* -maxdepth 1 -mmin +10 -type f)
            if [[ -n "$deletefile" ]]; then
                rm -rf /tmp/counter_dn/
            fi
            exit 1;
        fi
        echo -n 1 >> /tmp/counter_dn/counter
    else
        mkdir -p /tmp/counter_dn
        touch /tmp/counter_dn/counter
        echo -n 1 >> /tmp/counter_dn/counter
    fi
}

echo "get server-list..."
IFS=" " read -r -a SERVER_LISTS <<< "centerserver loginserver versionserver idipserver worldserver teamserver routerserver dbserver gameserver gateserver masterserver controlserver"

iteration=0
down_count=0
up_count=0
serverlength=${#SERVER_LISTS[@]}
string_logs=''
string_server=''
for((i=0; i<serverlength; i++))
do
    echo "Checking ${SERVER_LISTS[$i]}..."
    cmd1="ps -Ao pid= -o comm= "
    cmd2="grep ${SERVER_LISTS[$i]}"
    is_server_running=$(eval "$cmd1" | eval "$cmd2")
    if [ -z "${is_server_running}" ]; then
        # get log and send alert via email
        timestamp=$(date '+%Y-%m-%d %H:%M:%S %Z')
        echo -e "!!! CAUGHT SERVER DOWN: ${SERVER_LISTS[$i]}\n"
        string_server+="${SERVER_LISTS[$i]}, "
        cmd3="get_log ${SERVER_LISTS[$i]}"
        logs=$(eval "$cmd3")
        string_logs+="$timestamp || ${SERVER_LISTS[$i]}=======<br><br>$logs<br><br>"
        down_count=$((down_count+1))
    else
        echo -e "Server ${SERVER_LISTS[$i]} OK!\n"
        up_count=$((up_count+1))
    fi
    iteration=$((iteration+1))
    sleep 1
done

echo -e "[AVALON] All checked servers: $iteration"
echo -e "[AVALON] Server down: $down_count\nServer up: $up_count\n"
stats="[AVALON] Server down: $down_count<br>Server up: $up_count<br>"
string_server=$(echo "$string_server" | lcomma)
server_affected=$string_server


if [ -z "${server_affected}" ]; then
    # nothing to do
    tcp_connection_count=$(netstat -an | grep -c ESTABLISHED)
    # online_player_count=$(curl 127.0.0.1:81/sdk/healthcheck.php | jq -r .online_role)
    export TZ=Asia/Jakarta
    date=$(date '+%Y-%m-%d_%H-%M-%S_%Z')
    messages_up="==================================<br>SERVER UP AND RUNNING ${date}:white_check_mark:<br>==================================<br>tcp connection: ${tcp_connection_count}<br>player online: ${online_player_count}<br>==================================<br>"
    send_discord_server_up "$messages_up"
    # echo -e "online: ${online_player_count}"
    echo -e "online: ${tcp_connection_count}"
    echo -e "server up!!!"
    exit 0;
else
    # if server affcted > 0, send email
    check_counter
    message="=====Stats=====<br><br>$stats<br><br>Server down lists: $server_affected<br><br>======LOGS=======<br><br>$string_logs"
    send_discord "$message"
    # send_mail "$message"
    exit 0;
fi



