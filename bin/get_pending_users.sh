#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\get_pending_users.sh

# Set content type for JSON response
echo "Content-Type: application/json"
echo ""

# Path to pending users file
PENDING_FILE="../data/pending.txt"

# Initialize empty JSON array
echo -n "["

# Check if the file exists and is not empty
if [ -f "$PENDING_FILE" ] && [ -s "$PENDING_FILE" ]; then
    # Process the first line separately to handle JSON comma rules
    FIRST_LINE=true
    
    # Read each line from pending file
    while IFS=: read -r username password email phone date; do
        # If not the first line, add a comma separator
        if [ "$FIRST_LINE" = "true" ]; then
            FIRST_LINE=false
        else
            echo -n ","
        fi
        
        # Output JSON object with user details
        echo -n "{\"username\":\"$username\",\"email\":\"$email\",\"phone\":\"$phone\",\"date\":\"$date\"}"
    done < "$PENDING_FILE"
fi

# Close JSON array
echo "]"
