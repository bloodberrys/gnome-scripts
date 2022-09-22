#!/bin/bash

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
    api_key=7d28e6a1eb12151868987af95616b7f1-8d821f0c-1aeed30e
    subject="Server Healthcheck Down Detected"
    local _message=$1
    to="alfianvansykes@gmail.com"
    from='Gnome Automation <automation@verification.gnome-hub.com>'
    url="https://api.mailgun.net/v3/$domain/messages"
    req="curl -g --user 'api:${api_key}' '$url' -F from='${from}' -F to='${to}' -F subject='${subject}' -F html=\"${message}\""
    eval "$req"
}

send_discord(){
    webhook_url=https://discord.com/api/webhooks/990288785587707934/rPLMgznwPKHxRhlnzcILJgP_YjyVQaKcS_mnaLpXU6NWsY3WaPsPg9llgFibWVXB-0j_
    SUBJECT="!!!Server Healthcheck: Down Detected!!!"
    local _message=$1
    ADMIN_ROLE="<@&983558291261112370>"
    BOOSTER_ROLE="<@&983549809409552445>"
    CONTENT=$(echo $message | sed 's3<br>3\n3g')
    size=${#CONTENT}
    echo -e "$CONTENT" > /tmp/discordmsg.log
    if [[ $size -gt 2000 ]]; then
        CONTENT=${CONTENT:0:1500}
    fi
    payload_json=$(jq -n --arg content "$CONTENT" --arg subject "$SUBJECT" --arg ar "$ADMIN_ROLE" --arg br "$BOOSTER_ROLE" '{username: "Gnome-Automation", content: "\( $subject )\nCC: \( $br ) \( $ar )\n\n\( $content )"}')
    curl -g -F "payload_json=$payload_json" -F "file1=@/tmp/discordmsg.log" "$webhook_url"
}

send_discord_server_up(){
    webhook_url=https://discord.com/api/webhooks/1000428863735742494/IYw9zrf-BuL0_NFajzBFYpgrtv27gproOzBv2DpDc35np86USxNMCaAGyhZ7SRJNlk08
    SUBJECT="Server Online Status"
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
IFS=" " read -r -a SERVER_LISTS <<< "loginserver versionserver fmserver idipserver worldserver teamserver routerserver crossgameserver dbserver gameserver gateserver masterserver controlserver"

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

echo -e "All checked servers: $iteration"
echo -e "Server down: $down_count\nServer up: $up_count\n"
stats="Server down: $down_count<br>Server up: $up_count<br>"
string_server=$(echo "$string_server" | lcomma)
server_affected=$string_server


if [ -z "${server_affected}" ]; then
    # nothing to do
    tcp_connection_count=$(netstat -an | grep -c ESTABLISHED)
    online_player_count=$(curl 127.0.0.1:81/sdk/healthcheck.php | jq -r .online_role)
    export TZ=Asia/Jakarta
    date=$(date '+%Y-%m-%d_%H-%M-%S_%Z')
    messages_up="==================================<br>SERVER UP AND RUNNING ${date}:white_check_mark:<br>==================================<br>tcp connection: ${tcp_connection_count}<br>player online: ${online_player_count}<br>==================================<br>"
    send_discord_server_up "$messages_up"
    echo -e "online: ${online_player_count}"
    echo -e "online: ${tcp_connection_count}"
    echo -e "server up!!!"
    exit 0;
else
    # if server affcted > 0, send email
    check_counter
    message="=====Stats=====<br><br>$stats<br><br>Server down lists: $server_affected<br><br>======LOGS=======<br><br>$string_logs"
    send_discord "$message"
    send_mail "$message"
    exit 0;
fi



