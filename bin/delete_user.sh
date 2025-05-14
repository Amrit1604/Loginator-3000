#!/bin/bash

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"
DEBUG_LOG="../data/admin_actions.log"

# Read POST data
if [ ! -z "$CONTENT_LENGTH" ]; then
    POST_DATA=$(dd bs=1 count=$CONTENT_LENGTH 2>/dev/null)
else
    POST_DATA=""
fi

# Extract username from POST
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/+/ /g' | sed 's/%20/ /g')

# Log the deletion attempt
echo "$(date): Delete user attempt for user: $USERNAME" >> "$DEBUG_LOG"

# Check if username exists
USER_EXISTS=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -Nse "SELECT COUNT(*) FROM users WHERE username='$USERNAME';")

if [ "$USER_EXISTS" -eq 0 ]; then
    echo "$(date): Delete failed - User $USERNAME not found" >> "$DEBUG_LOG"
    echo '{"success":false,"message":"User not found"}'
    exit 0
fi

# Delete all assignments for the user
mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "DELETE FROM user_assignments WHERE username='$USERNAME';"

# Delete user from users table
mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "DELETE FROM users WHERE username='$USERNAME';"

# Verify deletion
USER_EXISTS=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -Nse "SELECT COUNT(*) FROM users WHERE username='$USERNAME';")

if [ "$USER_EXISTS" -eq 0 ]; then
    echo "$(date): User $USERNAME deleted successfully" >> "$DEBUG_LOG"
    echo '{"success":true,"message":"User deleted successfully"}'
    
    # Update export file
    "$(dirname "$0")/update_export.sh" &> /dev/null &
else
    echo "$(date): Failed to delete user $USERNAME" >> "$DEBUG_LOG"
    echo '{"success":false,"message":"Failed to delete user"}'
fi