#!/bin/bash

send_discord(){
    webhook_url=https://discord.com/api/webhooks/990288785587707934/rPLMgznwPKHxRhlnzcILJgP_YjyVQaKcS_mnaLpXU6NWsY3WaPsPg9llgFibWVXB-0j_
    SUBJECT="!!!Server restart by link click!!! server restarting..."
    local _message='server restarting...'
    ADMIN_ROLE="<@&983558291261112370>"
    BOOSTER_ROLE="<@&983549809409552445>"
    CONTENT=$(echo $message | sed 's3<br>3\n3g')
    size=${#CONTENT}
    echo -e "$CONTENT" > /tmp/discordmsg.log
    if [[ $size -gt 2000 ]]; then
        CONTENT=${CONTENT:0:1500}
    fi
    payload_json=$(jq -n --arg content "$CONTENT" --arg subject "$SUBJECT" --arg ar "$ADMIN_ROLE" --arg br "$BOOSTER_ROLE" '{username: "Gnome-Automation", content: "\( $subject )\nCC: \( $br ) \( $ar )\n\n\( $content )"}')
    curl -g -F "payload_json=$payload_json" "$webhook_url"
}

ipfiles="/var/www/html/suspected_ip/restart" # WE CAN SIMPLY CHANGE THIS FOR DEBUGGING
if [ ! -f "$ipfiles" ]; then
    echo "✗ File ${ipfiles} not found on your machine!"
    echo "exitting..."
    exit 1
else
    echo "✓ File ${ipfiles} is found, continue to the next task..."
    send_discord
    bash /data/s1001/restart-test.sh
    rm -rf /var/www/html/suspected_ip/restart
fi

