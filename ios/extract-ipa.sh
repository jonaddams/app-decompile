#!/bin/bash

################################################################################
# Extract IPA from Apple Configurator Cache
#
# Description: Copies IPA files from Apple Configurator's temporary cache
#              to a permanent location for analysis.
#
# Usage: ./extract-ipa.sh
#
# Author: Created for SDK Analyzer
################################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Directories
CACHE_DIR=~/Library/Group\ Containers/K36BKF7T3D.group.com.apple.configurator/Library/Caches/Assets/TemporaryItems/MobileApps
OUTPUT_DIR=~/Desktop/extracted-ipas

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         IPA Extractor for Apple Configurator                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "${BLUE}ℹ️  Looking for IPAs in Apple Configurator cache...${NC}"
echo ""

# Check if cache directory exists
if [ ! -d "$CACHE_DIR" ]; then
    echo -e "${RED}❌ Apple Configurator cache directory not found.${NC}"
    echo ""
    echo "This means Apple Configurator 2 hasn't been used yet."
    echo ""
    echo "Steps to get started:"
    echo "1. Install Apple Configurator 2 from Mac App Store"
    echo "2. Connect your iPhone via USB"
    echo "3. Open Apple Configurator 2"
    echo "4. Click on your device"
    echo "5. Go to: Actions → Add → Apps..."
    echo "6. Search for and add the app you want to analyze"
    echo "7. Run this script again"
    exit 1
fi

# Count IPAs in cache
IPA_COUNT=$(find "$CACHE_DIR" -name "*.ipa" 2>/dev/null | wc -l | tr -d ' ')

if [ "$IPA_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No IPAs found in cache.${NC}"
    echo ""
    echo "The cache is empty. To extract an IPA:"
    echo ""
    echo "1. Open Apple Configurator 2"
    echo "2. Connect your iPhone (if not already connected)"
    echo "3. Click on your device icon"
    echo "4. Go to: Actions → Add → Apps..."
    echo "5. Sign in with your Apple ID if prompted"
    echo "6. Search for the target app"
    echo "7. Select the app and click 'Add'"
    echo "8. Wait for download to complete"
    echo "9. Run this script immediately (before cache is cleared)"
    echo ""
    echo -e "${BLUE}Tip: Even if the app is already on your iPhone, Apple Configurator${NC}"
    echo -e "${BLUE}     will download a fresh copy to your Mac.${NC}"
    exit 0
fi

echo -e "${GREEN}✅ Found $IPA_COUNT IPA file(s) in cache:${NC}"
echo ""

# List IPAs with details
find "$CACHE_DIR" -name "*.ipa" -exec ls -lh {} \; | while read -r line; do
    echo "   $line"
done
echo ""

# Copy all IPAs to output directory
echo -e "${BLUE}ℹ️  Copying IPAs to: $OUTPUT_DIR${NC}"
cp "$CACHE_DIR"/*.ipa "$OUTPUT_DIR/" 2>/dev/null || true

echo -e "${GREEN}✅ Successfully copied IPA(s)!${NC}"
echo ""

# List copied files
echo -e "${GREEN}📦 Extracted IPAs available at:${NC}"
echo -e "${GREEN}   $OUTPUT_DIR${NC}"
echo ""

ls -lh "$OUTPUT_DIR"/*.ipa 2>/dev/null | while read -r line; do
    echo "   $line"
done

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Next Steps:${NC}"
echo ""
echo "To analyze an IPA with SDK Analyzer:"
echo ""
echo "Option 1 - Quick manual check:"
echo "  $ cd $OUTPUT_DIR"
echo "  $ unzip YourApp.ipa -d extracted"
echo "  $ ls extracted/Payload/*.app/Frameworks/"
echo ""
echo "Option 2 - Use the detection script (requires modification):"
echo "  $ ./detect-sdk-ios.sh --local-ipa $OUTPUT_DIR/YourApp.ipa"
echo ""
echo -e "${YELLOW}⚠️  Note: Cache files may be auto-deleted by Apple Configurator.${NC}"
echo -e "${YELLOW}   IPAs are now safely stored in: $OUTPUT_DIR${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
