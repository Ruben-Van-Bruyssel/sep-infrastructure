#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

# Variabelen
USERNAME="Ruben"
PASSWORD="24User25"
homeserver_url="http://matrix.i3-syndus.internal"
ROOM_FILE="/usr/local/share/matrix_room_id"
message_body="De webserver wordt afgesloten!"

# Controleer of het Room ID bestand bestaat
if [ ! -f "$ROOM_FILE" ]; then
    echo "Room ID bestand niet gevonden."
    exit 1
fi

room_id=$(cat "$ROOM_FILE")
if [ -z "$room_id" ]; then
    echo "Room ID is leeg."
    exit 1
fi

# Login en haal de access token op
login_payload=$(jq -n \
                  --arg user "$USERNAME" \
                  --arg pass "$PASSWORD" \
                  '{type: "m.login.password", user: $user, password: $pass}')

SERVER_URL="${homeserver_url}/_matrix/client/r0/login"
RESPONSE=$(curl -s -X POST -d "$login_payload" -H "Content-Type: application/json" "$SERVER_URL")
ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.access_token')

# Controleer of login gelukt is
if [ "$ACCESS_TOKEN" = "null" -o -z "$ACCESS_TOKEN" ]; then
    echo "Login mislukt: $RESPONSE"
    exit 1
fi

# Stuur het bericht
message_payload=$(jq -n \
                   --arg body "$message_body" \
                   '{msgtype: "m.text", body: $body}')

SEND_URL="${homeserver_url}/_matrix/client/r0/rooms/${room_id}/send/m.room.message?access_token=$ACCESS_TOKEN"
curl -s -X POST -d "$message_payload" -H "Content-Type: application/json" "$SEND_URL"