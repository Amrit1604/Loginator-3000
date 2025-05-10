#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\add_test_user.sh

echo "Content-Type: text/plain"
echo ""

# Set up paths
USERS_FILE="../data/users.txt"
ACTIVE_USERS="../data/active_users.txt"

# Ensure directories exist
mkdir -p ../data
mkdir -p ../data/sessions

# Create a guaranteed test user
TEST_USERNAME="test"
TEST_PASSWORD="test123"
TEST_EMAIL="test@example.com"
TEST_PHONE="1234567890"
TEST_DATE="2023-05-08"

# Remove any existing entry for this user
if [ -f "$USERS_FILE" ]; then
    grep -v "^$TEST_USERNAME:" "$USERS_FILE" > "$USERS_FILE.tmp"
    mv "$USERS_FILE.tmp" "$USERS_FILE"
fi

# Add the test user with clean format
echo "$TEST_USERNAME:$TEST_PASSWORD:$TEST_EMAIL:$TEST_PHONE:$TEST_DATE" >> "$USERS_FILE"

# Show the file contents
echo "Added test user to $USERS_FILE"
echo "-----------------------------"
echo "File contents:"
cat "$USERS_FILE"
echo ""
echo "-----------------------------"
echo "You can now log in with:"
echo "Username: $TEST_USERNAME"
echo "Password: $TEST_PASSWORD"