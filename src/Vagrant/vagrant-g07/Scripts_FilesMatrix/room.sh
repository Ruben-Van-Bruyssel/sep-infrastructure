#!/bin/bash

set -o errexit
# set -o nounset
set -o pipefail

# Variabelen
SERVER_URL="http://matrix.i3-syndus.internal/_matrix/client/r0/login"
USERNAME="Ruben"
PASSWORD="24User25"
homeserver_url="http://matrix.i3-syndus.internal"
ROOM_FILE="/usr/local/share/matrix_room_id"

# Login en haal de access token op
RESPONSE=$(curl -s -XPOST -d "{\"type\":\"m.login.password\", \"user\":\"$USERNAME\", \"password\":\"$PASSWORD\"}" "$SERVER_URL")
ACCESS_TOKEN=$(echo $RESPONSE | jq -r '.access_token')

# JSON data voor het creëren van de room
json_data='{
    "preset": "private_chat",
    "room_alias_name": "encrypted_room",
    "name": "Encrypted Room",
    "topic": "Secure Conversations",
    "visibility": "private",
    "creation_content": {"m.federate": false},
    "initial_state": [
        {
            "type": "m.room.encryption",
            "state_key": "",
            "content": {"algorithm": "m.megolm.v1.aes-sha2"}
        }
    ]
}'

# API call om de room te creëren en sla het room ID op
RESPONSE=$(curl -s -XPOST -d "$json_data" \
    -H "Content-Type: application/json" \
    "$homeserver_url/_matrix/client/r0/createRoom?access_token=$ACCESS_TOKEN")
ROOM_ID=$(echo $RESPONSE | jq -r '.room_id')
echo $ROOM_ID > $ROOM_FILE

# Zorg ervoor dat het Room ID niet null is
if [ "$ROOM_ID" == "null" ]; then
    echo "Failed to create room."
    exit 1
fi

echo $ROOM_ID > $ROOM_FILE