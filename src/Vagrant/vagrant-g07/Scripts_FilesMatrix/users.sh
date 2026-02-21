#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

SYNAPSE_VENV_DIR="/home/vagrant/synapse"
source "$SYNAPSE_VENV_DIR/bin/activate"

DOMAIN="matrix.i3-syndus.internal"
HOMESERVER_YAML="/home/vagrant/synapse/homeserver.yaml"
HS_URL="http://localhost:8008"

# List of users to create: USERNAME:PASSWORD
USERS=(
    "Ruben:24User25"
    "Jules:24User26"
)

# Wait for Synapse to start
until curl -s "$HS_URL/_matrix/client/versions" >/dev/null 2>&1; do
    echo "Waiting for Synapse to start..."
    sleep 2
done

# Function to register a user safely
register_user() {
    local USERNAME="$1"
    local PASSWORD="$2"
    local USER_ID="@${USERNAME}:${DOMAIN}"

    echo "Registering user $USER_ID (will skip if already exists)..."

    # Check if user already exists by trying a login
    if register_new_matrix_user -c "$HOMESERVER_YAML" "$HS_URL" -u "$USERNAME" -p "$PASSWORD" -a 2>&1 | grep -q "User ID already taken"; then
        echo "User $USER_ID already exists, skipping..."
    else
        register_new_matrix_user -c "$HOMESERVER_YAML" "$HS_URL" -u "$USERNAME" -p "$PASSWORD" -a || true
    fi
}

# Loop through users
for u in "${USERS[@]}"; do
    USERNAME="${u%%:*}"
    PASSWORD="${u##*:}"
    register_user "$USERNAME" "$PASSWORD"
done
