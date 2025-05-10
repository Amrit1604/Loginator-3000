#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\approve_user.sh

# Setup directories and files
DATA_DIR="../data"
PENDING="$DATA_DIR/pending.txt"  # Using the correct filename from get_pending_users.sh
USERS="$DATA_DIR/users.txt"
LOG="$DATA_DIR/admin_log.txt"
DEBUG_LOG="$DATA_DIR/debug.log"

mkdir -p "$DATA_DIR"
touch "$PENDING"
touch "$USERS"

# Debug logging
echo "===== APPROVE USER $(date) =====" >> "$DEBUG_LOG"

# Read POST data
if [ ! -z "$CONTENT_LENGTH" ]; then
    POST_DATA=$(cat)
    echo "POST data: $POST_DATA" >> "$DEBUG_LOG"
else
    POST_DATA=""
    echo "No POST data received" >> "$DEBUG_LOG"
fi

# Extract username
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//')
echo "Username to approve: $USERNAME" >> "$DEBUG_LOG"

echo "Pending file content:" >> "$DEBUG_LOG"
cat "$PENDING" >> "$DEBUG_LOG"

echo "Content-Type: application/json"
echo ""

# Check if user exists in pending
if grep -q "^$USERNAME:" "$PENDING"; then
    echo "User found in pending file" >> "$DEBUG_LOG"
    
    # Extract full user entry
    USER_ENTRY=$(grep "^$USERNAME:" "$PENDING")
    echo "User entry: $USER_ENTRY" >> "$DEBUG_LOG"
    
    # Add to users.txt - IMPORTANT: Ensure no extra blank lines or spaces
    echo "$USER_ENTRY" >> "$USERS"
    
    # Remove from pending
    grep -v "^$USERNAME:" "$PENDING" > "$PENDING.tmp"
    mv "$PENDING.tmp" "$PENDING"
    
    # Log the approval
    echo "$(date): Admin approved user $USERNAME" >> "$LOG"
    
    echo '{"success":true,"message":"User approved successfully"}'
else
    echo "User not found in pending file" >> "$DEBUG_LOG"
    echo '{"success":false,"message":"User not found in pending list"}'
fi