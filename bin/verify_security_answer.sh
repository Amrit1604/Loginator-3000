#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\verify_security_answer.sh

echo "Content-Type: application/json"
echo ""

# Get POST data
if [ -n "$CONTENT_LENGTH" ]; then
    POST_DATA=$(cat)
else
    echo '{"correct":false,"message":"No data received"}'
    exit 0
fi

# Extract username and answer
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/+/ /g' | sed 's/%20/ /g')
ANSWER=$(echo "$POST_DATA" | grep -o 'answer=[^&]*' | sed 's/answer=//' | sed 's/+/ /g' | sed 's/%20/ /g')

# URL decode the answer
ANSWER=$(echo "$ANSWER" | sed 's/%40/@/g' | sed 's/%21/!/g' | sed 's/%23/#/g' | sed 's/%24/$/g' | sed 's/%26/\&/g' | sed 's/%27/'\''/g' | sed 's/%28/(/g' | sed 's/%29/)/g' | sed 's/%2A/*/g' | sed 's/%2B/+/g' | sed 's/%2C/,/g' | sed 's/%3A/:/g' | sed 's/%3B/;/g' | sed 's/%3D/=/g' | sed 's/%3F/?/g')

# Path to users file
USERS_FILE="../data/users.txt"

if [ ! -f "$USERS_FILE" ]; then
    echo '{"correct":false,"message":"Users database not found"}'
    exit 0
fi

# Look for the user and extract stored answer (7th field)
USER_LINE=$(grep "^$USERNAME:" "$USERS_FILE")

if [ -n "$USER_LINE" ]; then
    STORED_ANSWER=$(echo "$USER_LINE" | cut -d':' -f7)
    
    # Case-insensitive comparison
    if [ "${ANSWER,,}" = "${STORED_ANSWER,,}" ]; then
        echo '{"correct":true}'
    else
        echo '{"correct":false,"message":"Incorrect answer"}'
    fi
else
    echo '{"correct":false,"message":"User not found"}'
fi