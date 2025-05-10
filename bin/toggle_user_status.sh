#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\toggle_user_status.sh

echo "Content-Type: application/json"
echo ""

# Read POST data
if [ ! -z "$CONTENT_LENGTH" ]; then
    POST_DATA=$(cat)
else
    POST_DATA=""
fi

# Extract username and status
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//')
STATUS=$(echo "$POST_DATA" | grep -o 'status=[^&]*' | sed 's/status=//')

# Paths
ACTIVE_USERS="../data/active_users.txt"
LOG_FILE="../data/admin_log.txt"

# Create files if they don't exist
mkdir -p ../data
touch "$ACTIVE_USERS"
touch "$LOG_FILE"

# Check for valid admin session (should be added for security)
# ...

# Update user status
if [ "$STATUS" = "active" ]; then
    # Add to active users
    if ! grep -q "^$USERNAME:" "$ACTIVE_USERS"; then
        echo "$USERNAME:$(date +%s)" >> "$ACTIVE_USERS"
    fi
    echo "$(date): Admin activated user $USERNAME" >> "$LOG_FILE"
    echo '{"success":true,"message":"User activated successfully"}'
else
    # Remove from active users
    grep -v "^$USERNAME:" "$ACTIVE_USERS" > "$ACTIVE_USERS.tmp"
    mv "$ACTIVE_USERS.tmp" "$ACTIVE_USERS"
    echo "$(date): Admin deactivated user $USERNAME" >> "$LOG_FILE"
    echo '{"success":true,"message":"User deactivated successfully"}'
fi