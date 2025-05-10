#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\reject_user.sh

# Set content type for JSON response
echo "Content-Type: application/json"
echo ""

# Read POST data
read -n $CONTENT_LENGTH POST_DATA

# Extract username
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/%20/ /g')

# Path to pending users file
PENDING_FILE="../data/pending.txt"

# Check if username is provided
if [ -z "$USERNAME" ]; then
    echo '{"success":false,"message":"Username is required"}'
    exit 0
fi

# Check if the user exists in pending
if ! grep -q "^$USERNAME:" "$PENDING_FILE"; then
    echo '{"success":false,"message":"User not found in pending registrations"}'
    exit 0
fi

# Create a temporary file
TEMP_FILE=$(mktemp)

# Remove the user from pending file
grep -v "^$USERNAME:" "$PENDING_FILE" > "$TEMP_FILE"

# Replace the old file with the new one
mv "$TEMP_FILE" "$PENDING_FILE"

# Log the rejection
echo "$(date): Admin rejected user registration: $USERNAME" >> "../data/logs.txt"

# Return success
echo "{\"success\":true,\"message\":\"User registration for $USERNAME has been rejected\"}"
