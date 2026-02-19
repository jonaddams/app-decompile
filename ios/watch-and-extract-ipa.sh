#!/bin/bash

################################################################################
# Auto-Watch and Extract IPA Script
#
# This script watches Apple Configurator's cache and automatically copies
# IPAs the INSTANT they appear (before Apple Configurator deletes them)
################################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Directories
CACHE_DIRS=(
    "$HOME/Library/Group Containers/K36BKF7T3D.group.com.apple.configurator/Library/Caches/Assets/TemporaryItems/MobileApps"
    "$HOME/Library/Containers/com.apple.configurator.ui/Data/tmp/TemporaryItems"
    "$HOME/Library/Containers/com.apple.configurator.xpc.InternetService/Data/tmp"
)
OUTPUT_DIR=~/Desktop/extracted-ipas

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         IPA Auto-Watcher (Real-Time Extractor)                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}✅ Output directory ready: $OUTPUT_DIR${NC}"
echo ""
echo -e "${YELLOW}📡 WATCHING FOR IPAs...${NC}"
echo ""
echo -e "${BLUE}Instructions:${NC}"
echo "1. Leave this script running in this Terminal window"
echo "2. In Apple Configurator 2:"
echo "   - Click your device"
echo "   - Go to: Actions → Add → Apps..."
echo "   - Select the app and click 'Add'"
echo "3. This script will automatically copy the IPA the moment it appears!"
echo ""
echo -e "${YELLOW}⏳ Monitoring in realtime... (Press Ctrl+C to stop)${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Function to copy IPA
copy_ipa() {
    local ipa_file="$1"
    if [ -f "$ipa_file" ]; then
        local filename=$(basename "$ipa_file")
        local timestamp=$(date +%Y%m%d-%H%M%S)
        local dest="$OUTPUT_DIR/${filename%.ipa}-${timestamp}.ipa"

        echo -e "${GREEN}🎯 IPA DETECTED!${NC}"
        echo "   Source: $ipa_file"
        echo "   Copying to: $dest"

        cp "$ipa_file" "$dest"

        if [ -f "$dest" ]; then
            local size=$(du -h "$dest" | cut -f1)
            echo -e "${GREEN}✅ SUCCESS! Copied $size${NC}"
            echo ""
            echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${GREEN}IPA saved to: $dest${NC}"
            echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo "You can now analyze it with:"
            echo "  ./detect-sdk-ios.sh --local-ipa \"$dest\""
            echo ""
            echo -e "${YELLOW}⏳ Continuing to watch for more IPAs...${NC}"
            echo ""
        else
            echo -e "${RED}❌ Copy failed${NC}"
        fi
    fi
}

# Check for fswatch
if command -v fswatch &> /dev/null; then
    # Use fswatch (better performance)
    echo -e "${BLUE}ℹ️  Using fswatch for monitoring${NC}"
    echo ""

    # Watch all possible cache directories
    for cache_dir in "${CACHE_DIRS[@]}"; do
        if [ -d "$cache_dir" ]; then
            echo "Monitoring: $cache_dir"
        fi
    done
    echo ""

    # Create directories if they don't exist
    for cache_dir in "${CACHE_DIRS[@]}"; do
        mkdir -p "$cache_dir" 2>/dev/null || true
    done

    # Watch for new .ipa files
    fswatch -0 -r -e ".*" -i "\.ipa$" "${CACHE_DIRS[@]}" 2>/dev/null | while read -d "" ipa_file; do
        copy_ipa "$ipa_file"
    done
else
    # Fallback: polling method (slower but works without fswatch)
    echo -e "${YELLOW}⚠️  fswatch not found, using polling method (slower)${NC}"
    echo "   To install fswatch for faster detection: brew install fswatch"
    echo ""

    LAST_SEEN=""

    while true; do
        for cache_dir in "${CACHE_DIRS[@]}"; do
            if [ -d "$cache_dir" ]; then
                # Use find to avoid glob expansion issues
                while IFS= read -r ipa; do
                    if [ -f "$ipa" ] && [ "$ipa" != "$LAST_SEEN" ]; then
                        copy_ipa "$ipa"
                        LAST_SEEN="$ipa"
                    fi
                done < <(find "$cache_dir" -maxdepth 1 -name "*.ipa" -type f 2>/dev/null)
            fi
        done

        # Also check for any .ipa in home Library
        while IFS= read -r ipa; do
            if [ -n "$ipa" ] && [ "$ipa" != "$LAST_SEEN" ]; then
                copy_ipa "$ipa"
                LAST_SEEN="$ipa"
            fi
        done < <(find ~/Library -name "*.ipa" -type f -mmin -1 2>/dev/null)

        sleep 0.5  # Check twice per second
    done
fi
