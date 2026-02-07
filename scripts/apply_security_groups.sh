#!/bin/bash
set -u

# Usage: ./apply_security_groups.sh <security-group-id> <json-template-file>
SG_ID=$1
JSON_TEMPLATE=$2

# --- 1. Validation ---
if [[ -z "$SG_ID" || -z "$JSON_TEMPLATE" ]]; then
    echo "Usage: $0 <sg-id> <path-to-json>"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed. Please install it (sudo apt install jq)."
    exit 1
fi

# --- 2. Dynamic IP Injection (Solving the "Magic IP" Issue) ---
# Check if the template needs IP injection
if grep -q "YOUR_IP" "$JSON_TEMPLATE"; then
    echo "🔍 Detected 'YOUR_IP' placeholder. Fetching public IP..."
    MY_IP=$(curl -s https://checkip.amazonaws.com)
    
    if [[ -z "$MY_IP" ]]; then
        echo "❌ Error: Could not fetch public IP."
        exit 1
    fi
    
    echo "🌐 Public IP is: $MY_IP"
    
    # Create a temporary file with the real IP
    TEMP_JSON=$(mktemp)
    sed "s|YOUR_IP|$MY_IP|g" "$JSON_TEMPLATE" > "$TEMP_JSON"
    TARGET_FILE="$TEMP_JSON"
else
    TARGET_FILE="$JSON_TEMPLATE"
fi

# --- 3. Applying Rules with Idempotency ---
echo "🚀 Applying rules to SG: $SG_ID..."

# We capture the error output to check for duplicates
OUTPUT=$(aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --cli-input-json "file://$TARGET_FILE" 2>&1)

EXIT_CODE=$?

# Clean up temp file if it exists
[ "$TARGET_FILE" != "$JSON_TEMPLATE" ] && rm "$TARGET_FILE"

# --- 4. Smart Error Handling ---
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Success: Rules applied."
elif echo "$OUTPUT" | grep -q "InvalidPermission.Duplicate"; then
    echo "⚠️  Note: Rules already exist (Idempotent). Skipping."
    exit 0 # Exit with success because the desired state is achieved
else
    echo "❌ Error: Failed to apply rules."
    echo "$OUTPUT"
    exit 1
fi
