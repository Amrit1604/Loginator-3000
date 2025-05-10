#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\get_all_users.sh

echo "Content-Type: application/json"
echo ""

# Set up paths
USERS_FILE="../data/users.txt"
ACTIVE_USERS="../data/active_users.txt"
SESSIONS_DIR="../data/sessions"

# Create files if they don't exist
mkdir -p "$SESSIONS_DIR"
touch "$USERS_FILE"
touch "$ACTIVE_USERS"

# Create a temporary file with the current time
CURRENT_TIME=$(date +%s)
touch "$ACTIVE_USERS.tmp"

# Get list of active sessions by scanning sessions directory
for session_file in "$SESSIONS_DIR"/*_session.txt; do
    if [ -f "$session_file" ]; then
        # Extract username from session file name
        filename=$(basename "$session_file")
        username="${filename%_session.txt}"
        
        # Record as active
        echo "$username:$CURRENT_TIME" >> "$ACTIVE_USERS.tmp"
    fi
done

# Get any additional active users from active_users.txt
while IFS=: read -r user timestamp; do
    if [ ! -z "$user" ]; then
        # Check if not already in temp file
        if ! grep -q "^$user:" "$ACTIVE_USERS.tmp"; then
            echo "$user:$timestamp" >> "$ACTIVE_USERS.tmp"
        fi
    fi
done < "$ACTIVE_USERS"

# Replace active users file with updated one
mv "$ACTIVE_USERS.tmp" "$ACTIVE_USERS"

# Start JSON array
echo "["

# Process all users
FIRST=true
while IFS=: read -r username password email phone date rest; do
    # Skip empty lines
    if [ -z "$username" ]; then
        continue
    fi
    
    # Check if user is active
    ACTIVE="false"
    if grep -q "^$username:" "$ACTIVE_USERS"; then
        ACTIVE="true"
    fi
    
    # Get container status (mock data for now)
    CONTAINER="stopped"
    if [ "$ACTIVE" = "true" ]; then
        CONTAINER="running"
    fi
    
    # Add comma separator between items (except first)
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo ","
    fi
    
    # Output user as JSON object
    echo "{\"username\":\"$username\",\"email\":\"$email\",\"phone\":\"$phone\",\"date\":\"$date\",\"active\":$ACTIVE,\"container\":\"$CONTAINER\"}"
    
done < "$USERS_FILE"

# End JSON array
echo "]"