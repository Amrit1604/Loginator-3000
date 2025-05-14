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

# Extract data from POST
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/+/ /g' | sed 's/%20/ /g')
WORK=$(echo "$POST_DATA" | grep -o 'work=[^&]*' | sed 's/work=//' | sed 's/+/ /g' | sed 's/%20/ /g')

# Log the assignment attempt
echo "$(date): Work assignment attempt for user: $USERNAME" >> "$DEBUG_LOG"

# Check if username exists
USER_EXISTS=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -Nse "SELECT COUNT(*) FROM users WHERE username='$USERNAME';")

if [ "$USER_EXISTS" -eq 0 ]; then
    echo "$(date): Assignment failed - User $USERNAME not found" >> "$DEBUG_LOG"
    echo '{"success":false,"message":"User not found"}'
    exit 0
fi

# Check if user_assignments table exists, create if not
mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "
CREATE TABLE IF NOT EXISTS user_assignments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    assignment TEXT NOT NULL,
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending'
);"

# Add work assignment to the database
mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "
INSERT INTO user_assignments (username, assignment)
VALUES ('$USERNAME', '$WORK');"

# Check if assignment was added
ASSIGNMENT_ADDED=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -Nse "SELECT COUNT(*) FROM user_assignments WHERE username='$USERNAME' AND assignment='$WORK';")

if [ "$ASSIGNMENT_ADDED" -gt 0 ]; then
    echo "$(date): Work assigned to user $USERNAME successfully" >> "$DEBUG_LOG"
    echo '{"success":true,"message":"Work assigned successfully"}'
else
    echo "$(date): Failed to assign work to user $USERNAME" >> "$DEBUG_LOG"
    echo '{"success":false,"message":"Failed to assign work"}'
fi