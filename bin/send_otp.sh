#!/bin/bash

username="$1"
otp=$((100000 + RANDOM % 900000))
otp_expire=$(date -d "+5 minutes" +%s)

echo "$username:$otp:$otp_expire" >> ../data/reset_tokens.txt

# In a real setup: send email or SMS here
echo "$(date) | OTP for $username is $otp" >> ../data/logs.txt
