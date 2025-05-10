#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\generate_sample_logs.sh

# Use this script to generate sample user logs for testing

# Path to user activity logs
LOGS_DIR="../data/logs"
USERS_FILE="../data/users.txt"

# Create logs directory if it doesn't exist
mkdir -p "$LOGS_DIR"

# Sample websites
WEBSITES=(
  "https://example.com/dashboard"
  "https://example.com/profile"
  "https://example.com/settings"
  "https://example.com/reports"
  "https://example.com/documents"
  "https://example.com/projects"
  "https://example.com/calendar"
  "https://example.com/messages"
  "https://example.com/tasks"
  "https://google.com/search?q=linux+commands"
  "https://stackoverflow.com/questions/tagged/bash"
  "https://github.com/torvalds/linux"
)

# Sample downloads
DOWNLOADS=(
  "annual_report.pdf"
  "invoice_202305.xlsx"
  "user_manual.pdf"
  "contract_template.docx"
  "company_logo.png"
  "presentation.pptx"
  "data_backup.zip"
  "source_code.tar.gz"
)

# Sample activities
ACTIVITIES=(
  "Logged into the system"
  "Updated profile information"
  "Changed account settings"
  "Created new document"
  "Shared file with team"
  "Added new contact"
  "Sent message to support"
  "Generated monthly report"
  "Requested password reset"
  "Added payment method"
)

# Get all usernames from users.txt
if [ -f "$USERS_FILE" ]; then
  while IFS=: read -r username rest || [ -n "$username" ]; do
    # Skip empty lines
    if [ -z "$username" ]; then
      continue
    fi
    
    echo "Generating logs for user: $username"
    USER_LOG="$LOGS_DIR/${username}_activity.log"
    
    # Clear existing log if it exists
    > "$USER_LOG"
    
    # Add login entry
    LOGIN_TIME=$(date -d "-$((RANDOM % 120)) minutes" "+%Y-%m-%d %H:%M:%S")
    echo "[$LOGIN_TIME] User logged in successfully" >> "$USER_LOG"
    
    # Generate random number of entries (8-15)
    NUM_ENTRIES=$((RANDOM % 8 + 8))
    
    for ((i=1; i<=NUM_ENTRIES; i++)); do
      # Random timestamp after login
      MINUTES_AFTER=$((i * (RANDOM % 5 + 1)))
      TIMESTAMP=$(date -d "$LOGIN_TIME +$MINUTES_AFTER minutes" "+%Y-%m-%d %H:%M:%S")
      
      # Determine activity type
      ACTIVITY_TYPE=$((RANDOM % 10))
      
      if [ $ACTIVITY_TYPE -lt 5 ]; then
        # Website visit
        WEBSITE_INDEX=$((RANDOM % ${#WEBSITES[@]}))
        ACTIVITY="User visited webpage: ${WEBSITES[$WEBSITE_INDEX]}"
      elif [ $ACTIVITY_TYPE -lt 8 ]; then
        # Download
        DOWNLOAD_INDEX=$((RANDOM % ${#DOWNLOADS[@]}))
        ACTIVITY="User downloaded file: ${DOWNLOADS[$DOWNLOAD_INDEX]}"
      else
        # Other activity
        ACTIVITY_INDEX=$((RANDOM % ${#ACTIVITIES[@]}))
        ACTIVITY="${ACTIVITIES[$ACTIVITY_INDEX]}"
      fi
      
      # Log the activity with timestamp
      echo "[$TIMESTAMP] $ACTIVITY" >> "$USER_LOG"
    done
    
    echo "Created $NUM_ENTRIES log entries for $username"
    
  done < "$USERS_FILE"
  
  echo "Sample logs with web browsing and downloads generated successfully"
else
  echo "Users file not found: $USERS_FILE"
fi