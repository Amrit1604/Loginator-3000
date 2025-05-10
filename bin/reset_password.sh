#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\reset_password.sh

echo "Content-Type: application/json"
echo ""

# Get POST data
if [ -n "$CONTENT_LENGTH" ]; then
    POST_DATA=$(cat)
else
    echo '{"success":false,"message":"No data received"}'
    exit 0
fi

# Extract username and new password
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/+/ /g' | sed 's/%20/ /g')
NEW_PASSWORD=$(echo "$POST_DATA" | grep -o 'password=[^&]*' | sed 's/password=//' | sed 's/+/ /g')

# Path to users file
USERS_FILE="../data/users.txt"
TEMP_FILE=$(mktemp)

if [ ! -f "$USERS_FILE" ]; then
    echo '{"success":false,"message":"Users database not found"}'
    exit 0
fi

# Lock for writing
exec 9>$USERS_FILE.lock
if ! flock -n 9; then
    echo '{"success":false,"message":"System busy, try again"}'
    exit 0
fi

# Flag to track if we updated the user
UPDATED=false

# Read line by line, update the password for matching user
while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^"$USERNAME": ]]; then
        # Extract all fields
        EMAIL=$(echo "$line" | cut -d':' -f3)
        PHONE=$(echo "$line" | cut -d':' -f4)
        REG_DATE=$(echo "$line" | cut -d':' -f5)
        SEC_QUESTION=$(echo "$line" | cut -d':' -f6)
        SEC_ANSWER=$(echo "$line" | cut -d':' -f7)
        
        # Write updated user line
        echo "$USERNAME:$NEW_PASSWORD:$EMAIL:$PHONE:$REG_DATE:$SEC_QUESTION:$SEC_ANSWER" >> "$TEMP_FILE"
        UPDATED=true
    else
        # Keep other lines as is
        echo "$line" >> "$TEMP_FILE"
    fi
done < "$USERS_FILE"

# Replace original with updated file
mv "$TEMP_FILE" "$USERS_FILE"

# Release lock
flock -u 9

if [ "$UPDATED" = true ]; then
    # Log the password reset
    echo "$(date): Password reset for user $USERNAME" >> "../data/password_reset_log.txt"
    echo '{"success":true,"message":"Password reset successful"}'
else
    echo '{"success":false,"message":"User not found"}'
fi