#!/bin/bash
# Utility script to demonstrate how to apply the JSON configurations
# Usage: ./apply_security_groups.sh <security-group-id> <json-file>

SG_ID=$1
JSON_FILE=$2

if [[ -z "$SG_ID" || -z "$JSON_FILE" ]]; then
    echo "Usage: $0 <sg-id> <path-to-json>"
    echo "Example: $0 sg-012345 examples/bastion-sg.json"
    exit 1
fi

echo "Applying rules from $JSON_FILE to Security Group $SG_ID..."

# AWS CLI command to merge the JSON rules into the existing Security Group
aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --cli-input-json "file://$JSON_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Successfully applied security rules."
else
    echo "❌ Failed to apply rules. Check your JSON format or permissions."
fi
