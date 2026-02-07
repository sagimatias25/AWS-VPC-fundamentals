#!/bin/bash
set -euo pipefail

# --- Configuration ---
TARGET_BUCKET=${1:-"Please-Provide-Bucket-Name"}

# --- Colors ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Dependency Check ---
for cmd in aws curl; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}Error: $cmd is not installed.${NC}"
        exit 1
    fi
done

echo -e "${NC}--- Starting Network Verification ---${NC}"

# 1. Test Internet Isolation (Using curl instead of ping)
# Why: ICMP (ping) is often blocked by corporate firewalls. 
# HTTP (curl) proves we have no route to the web.
echo -n "[1] Testing Internet Isolation (curl google.com)... "

# We use --connect-timeout 2 to fail fast
if ! curl -I --connect-timeout 2 https://google.com > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PASS${NC}: Internet is unreachable (As expected)."
else
    echo -e "${RED}❌ FAIL${NC}: Internet is reachable! Isolation broken."
    exit 1
fi

# 2. Test S3 Connectivity
if [ "$TARGET_BUCKET" != "Please-Provide-Bucket-Name" ]; then
    echo -n "[2] Testing S3 Connectivity via VPC Endpoint... "
    if aws s3 ls "s3://$TARGET_BUCKET" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}: S3 Bucket is accessible."
    else
        echo -e "${RED}❌ FAIL${NC}: Cannot reach S3. Check VPC Endpoint or IAM Role."
        exit 1
    fi
else
    echo -e "${NC}⚠️  Skipping S3 test (No bucket provided)${NC}"
fi

echo -e "${NC}--- Verification Complete ---${NC}"
