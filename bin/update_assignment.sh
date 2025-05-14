#!/bin/bash

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"
DEBUG_LOG="../data/user_actions.log"

# Read POST data
if [ ! -z "$CONTENT_LENGTH" ]; then
    POST_DATA=$(dd bs=1 count=$CONTENT_LENGTH 2>/dev/null)
else
    POST_DATA=""
fi

# Extract data from POST
ASSIGNMENT_ID=$(echo "$POST_DATA" | grep -o 'id=[^&]*' | sed 's/id=//')
STATUS=$(echo "$POST_DATA" | grep -o 'status=[^&]*' | sed 's/status=//')

# Log the update attempt
echo "$(date): Update assignment status attempt for assignment ID: $ASSIGNMENT_ID" >> "$DEBUG_LOG"

# Update assignment status
mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "
UPDATE user_assignments 
SET status='$STATUS' 
WHERE id='$ASSIGNMENT_ID';"

# Check if update was successful
STATUS_UPDATED=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -Nse "
SELECT COUNT(*) 
FROM user_assignments 
WHERE id='$ASSIGNMENT_ID' AND status='$STATUS';")

if [ "$STATUS_UPDATED" -gt 0 ]; then
    echo "$(date): Assignment ID $ASSIGNMENT_ID status updated to $STATUS" >> "$DEBUG_LOG"
    echo '{"success":true,"message":"Assignment status updated"}'
else
    echo "$(date): Failed to update assignment ID $ASSIGNMENT_ID status" >> "$DEBUG_LOG"
    echo '{"success":false,"message":"Failed to update assignment status"}'
fi