#!/bin/bash
set -euo pipefail

# --- Configuration ---
TARGET_BUCKET="sage-secret-bucket" 

# --- Colors ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${NC}--- Starting Network Verification ---${NC}"

# 1. Test Internet Isolation
echo -n "[1] Testing Internet Isolation (ping google.com)... "
if ! ping -c 3 -W 2 google.com > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PASS${NC}: Internet is unreachable (As expected)."
else
    echo -e "${RED}❌ FAIL${NC}: Internet is reachable! Check Route Tables."
    exit 1
fi

# 2. Test S3 Connectivity
echo -n "[2] Testing S3 Connectivity via VPC Endpoint... "
if aws s3 ls "s3://$TARGET_BUCKET" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PASS${NC}: S3 Bucket is accessible."
else
    echo -e "${RED}❌ FAIL${NC}: Cannot reach S3. Check VPC Endpoint configuration."
    exit 1
fi

echo -e "${NC}--- Verification Complete ---${NC}"
