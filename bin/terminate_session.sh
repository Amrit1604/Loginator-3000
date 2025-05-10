#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\terminate_session.sh

# Set Content-Type header
echo "Content-Type: application/json"
echo ""

# Read POST data
if [ ! -z "$CONTENT_LENGTH" ]; then
    POST_DATA=$(cat)
else
    echo '{"success":false,"message":"No POST data received"}'
    exit 0
fi

# Extract username and session
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/+/ /g')
SESSION=$(echo "$POST_DATA" | grep -o 'session=[^&]*' | sed 's/session=//' | sed 's/+/ /g')

# Path to session files
SESSIONS_FILE="../data/user_sessions.txt"
USER_SESSION_FILE="../data/sessions/${USERNAME}_session.txt"

# Check if files exist
if [ ! -f "$SESSIONS_FILE" ]; then
    echo '{"success":false,"message":"Sessions file not found"}'
    exit 0
fi

# Remove session from main sessions file
if [ -f "$SESSIONS_FILE" ]; then
    grep -v "$SESSION:" "$SESSIONS_FILE" > "$SESSIONS_FILE.tmp"
    mv "$SESSIONS_FILE.tmp" "$SESSIONS_FILE"
fi

# Remove user session file
if [ -f "$USER_SESSION_FILE" ]; then
    rm "$USER_SESSION_FILE"
fi

# Log the action
echo "$(date): Admin terminated session for user $USERNAME" >> "../data/login_log.txt"

# Log to user activity log
LOGS_DIR="../data/logs"
USER_LOG="$LOGS_DIR/${USERNAME}_activity.log"
mkdir -p "$LOGS_DIR"
echo "[$(date "+%Y-%m-%d %H:%M:%S")] Session terminated by administrator" >> "$USER_LOG"

echo '{"success":true,"message":"Session terminated successfully"}'