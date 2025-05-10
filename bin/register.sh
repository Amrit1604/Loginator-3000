#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\register.sh

# Create data directory if it doesn't exist
mkdir -p ../data
DEBUG_LOG="../data/debug.log"
PENDING_FILE="../data/pending.txt"

echo "=== REGISTRATION $(date) ===" >> "$DEBUG_LOG"

# Read POST data
if [ ! -z "$CONTENT_LENGTH" ]; then
    POST_DATA=$(cat)
    echo "POST data: $POST_DATA" >> "$DEBUG_LOG"
else
    POST_DATA=""
    echo "No POST data" >> "$DEBUG_LOG"
fi

# Extract form data
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//')
PASSWORD=$(echo "$POST_DATA" | grep -o 'password=[^&]*' | sed 's/password=//' | sed 's/%40/@/g' | sed 's/%21/!/g' | sed 's/%23/#/g' | sed 's/%24/$/g')
EMAIL=$(echo "$POST_DATA" | grep -o 'email=[^&]*' | sed 's/email=//')
PHONE=$(echo "$POST_DATA" | grep -o 'phone=[^&]*' | sed 's/phone=//')

# Extract security question and answer
SECURITY_QUESTION=$(echo "$POST_DATA" | grep -o 'security_question=[^&]*' | sed 's/security_question=//')
SECURITY_ANSWER=$(echo "$POST_DATA" | grep -o 'security_answer=[^&]*' | sed 's/security_answer=//' | sed 's/+/ /g' | sed 's/%20/ /g')

# URL decode the security answer for special characters
SECURITY_ANSWER=$(echo "$SECURITY_ANSWER" | sed 's/%40/@/g' | sed 's/%21/!/g' | sed 's/%23/#/g' | sed 's/%24/$/g' | sed 's/%26/\&/g' | sed 's/%27/'\''/g' | sed 's/%28/(/g' | sed 's/%29/)/g' | sed 's/%2A/*/g' | sed 's/%2B/+/g' | sed 's/%2C/,/g' | sed 's/%3A/:/g' | sed 's/%3B/;/g' | sed 's/%3D/=/g' | sed 's/%3F/?/g')

echo "Registering: $USERNAME, $EMAIL" >> "$DEBUG_LOG"
echo "Security Question: $SECURITY_QUESTION" >> "$DEBUG_LOG"

# Input validation
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$EMAIL" ] || [ -z "$SECURITY_QUESTION" ] || [ -z "$SECURITY_ANSWER" ]; then
    echo "Missing required fields" >> "$DEBUG_LOG"
    echo "Content-Type: application/json"
    echo ""
    echo '{"success":false,"message":"All fields are required including security question and answer."}'
    exit 0
fi

# Check if username already exists in pending or users
USERS_FILE="../data/users.txt"

if grep -q "^$USERNAME:" "$USERS_FILE" 2>/dev/null; then
    echo "Username already exists in users.txt" >> "$DEBUG_LOG"
    echo "Content-Type: application/json"
    echo ""
    echo '{"success":false,"message":"Username already exists. Please choose another."}'
    exit 0
fi

if grep -q "^$USERNAME:" "$PENDING_FILE" 2>/dev/null; then
    echo "Username already exists in pending.txt" >> "$DEBUG_LOG"
    echo "Content-Type: application/json"
    echo ""
    echo '{"success":false,"message":"Username is already pending approval. Please wait."}'
    exit 0
fi

# Save to pending.txt with security question and answer
# New format: username:password:email:phone:registration_date:security_question:security_answer
echo "$USERNAME:$PASSWORD:$EMAIL:$PHONE:$(date +%Y-%m-%d):$SECURITY_QUESTION:$SECURITY_ANSWER" >> "$PENDING_FILE"
echo "User added to pending.txt with security question" >> "$DEBUG_LOG"

echo "Content-Type: application/json"
echo ""
echo '{"success":true,"message":"Registration successful! Your account is pending approval."}'