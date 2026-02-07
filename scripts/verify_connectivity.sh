#!/bin/bash
set -euo pipefail

# --- Configuration ---
TARGET_BUCKET=${1:-"Please-Provide-Bucket-Name"}

# --- Colors ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Dependency Check ---
# A Senior Engineer always checks if dependencies exist before running
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed.${NC}"
    exit 1
fi

echo -e "${NC}--- Starting Network Verification ---${NC}"

if [ "$TARGET_BUCKET" == "Please-Provide-Bucket-Name" ]; then
    echo -e "${RED}⚠️  WARNING: No bucket name provided.${NC}"
    echo "Usage: $0 <your-bucket-name>"
else
    echo "Target Bucket: $TARGET_BUCKET"
fi

# 1. Test Internet Isolation
echo -n "[1] Testing Internet Isolation (ping google.com)... "
# We expect this to fail, so we suppress output
if ! ping -c 3 -W 2 google.com > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PASS${NC}: Internet is unreachable (As expected)."
else
    echo -e "${RED}❌ FAIL${NC}: Internet is reachable! Check Route Tables."
    exit 1
fi

# 2. Test S3 Connectivity
if [ "$TARGET_BUCKET" != "Please-Provide-Bucket-Name" ]; then
    echo -n "[2] Testing S3 Connectivity via VPC Endpoint... "
    # Using IAM Role (Metadata service) automatically
    if aws s3 ls "s3://$TARGET_BUCKET" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}: S3 Bucket is accessible."
    else
        echo -e "${RED}❌ FAIL${NC}: Cannot reach S3. Verify IAM Role is attached to EC2."
        exit 1
    fi
fi

echo -e "${NC}--- Verification Complete ---${NC}"
