#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\get_container_status.sh

echo "Content-Type: application/json"
echo ""

# In a real system, this would query Docker or another container system
# For demo purposes, we'll generate some sample data

# Create container logs directory if it doesn't exist
mkdir -p ../data/container_logs

# Read active users
ACTIVE_USERS="../data/active_users.txt"

# Start JSON response
echo "["

# Process each active user
FIRST=true
while IFS=: read -r username timestamp; do
    # Skip empty lines
    if [ -z "$username" ]; then
        continue
    fi
    
    # Generate random container data
    STATUS="running"
    STARTED="$(date -d "@$(($(date +%s) - RANDOM % 86400))" "+%Y-%m-%d %H:%M:%S")"
    CPU=$((RANDOM % 30 + 1))
    MEMORY="$((RANDOM % 500 + 100))MB / 2GB"
    
    # Generate or read recent logs
    LOGS_FILE="../data/container_logs/${username}_container.log"
    if [ ! -f "$LOGS_FILE" ]; then
        echo "$(date): Container started for user $username" > "$LOGS_FILE"
        echo "$(date): User logged in" >> "$LOGS_FILE"
        echo "$(date): Running system updates" >> "$LOGS_FILE"
        echo "$(date): Starting SSH service" >> "$LOGS_FILE"
    fi
    
    # Get recent logs (last 5 lines)
    RECENT_LOGS=$(tail -5 "$LOGS_FILE" | sed 's/"/\\"/g' | tr '\n' '\\' | sed 's/\\/\\n/g')
    
    # Add comma for all but first item
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo ","
    fi
    
    # Output container data as JSON
    echo "  {\"user\":\"$username\",\"status\":\"$STATUS\",\"started\":\"$STARTED\",\"cpu\":$CPU,\"memory\":\"$MEMORY\",\"recent_logs\":\"$RECENT_LOGS\"}"
    
done < "$ACTIVE_USERS"

# End JSON array
echo "]"