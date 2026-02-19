#!/bin/bash

################################################################################
# APK Download Helper Script
#
# Description: Helps non-technical users download APK files easily
# Usage: ./download-apk-helper.sh <package-name-or-url>
################################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ ERROR: $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# Extract package name from URL or use as-is
PACKAGE_NAME="$1"

if [[ $PACKAGE_NAME == *"play.google.com"* ]]; then
    PACKAGE_NAME=$(echo "$PACKAGE_NAME" | grep -oE 'id=[^&]+' | cut -d'=' -f2)
fi

if [ -z "$PACKAGE_NAME" ]; then
    print_error "Package name or Play Store URL required"
    echo ""
    echo "Usage: $0 <package-name-or-play-store-url>"
    echo ""
    echo "Examples:"
    echo "  $0 com.example.app"
    echo "  $0 'https://play.google.com/store/apps/details?id=com.example.app'"
    exit 1
fi

echo ""
echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║           APK Download Helper for Non-Technical Users          ║${NC}"
echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

print_info "Package: $PACKAGE_NAME"
echo ""

# Try multiple download sources
echo -e "${BOLD}Attempting automatic download from multiple sources...${NC}"
echo ""

# Method 1: APKPure direct download
print_info "Trying APKPure..."
if curl -L -o "downloaded.apk" "https://d.apkpure.com/b/APK/${PACKAGE_NAME}?version=latest" 2>/dev/null; then
    if file "downloaded.apk" 2>/dev/null | grep -q "Zip archive data"; then
        print_success "Downloaded from APKPure!"
        echo ""
        print_info "APK saved as: downloaded.apk"
        echo ""

        # Get APK info
        if command -v aapt &> /dev/null; then
            print_info "APK Info:"
            aapt dump badging "downloaded.apk" 2>/dev/null | grep -E "package:|application-label:" | head -2
        fi

        echo ""
        print_success "Ready to analyze!"
        echo ""
        echo "Run the detection script:"
        echo -e "  ${GREEN}./detect-sdk-android.sh -s pspdfkit -s nutrient -f downloaded.apk${NC}"
        echo ""
        exit 0
    fi
fi

# Method 2: Check if user has ADB and app is on device
if command -v adb &> /dev/null; then
    print_info "Trying connected Android device..."

    if adb devices 2>/dev/null | grep -q "device$"; then
        apk_path=$(adb shell pm path "$PACKAGE_NAME" 2>/dev/null | cut -d':' -f2 | tr -d '\r')

        if [ -n "$apk_path" ]; then
            print_info "Found app on connected device!"
            adb pull "$apk_path" "downloaded.apk" &>/dev/null

            if [ -f "downloaded.apk" ]; then
                print_success "Extracted from Android device!"
                echo ""
                print_info "APK saved as: downloaded.apk"
                echo ""
                print_success "Ready to analyze!"
                echo ""
                echo "Run the detection script:"
                echo -e "  ${GREEN}./detect-sdk-android.sh -s pspdfkit -s nutrient -f downloaded.apk${NC}"
                echo ""
                exit 0
            fi
        fi
    fi
fi

# All automatic methods failed - provide manual instructions
rm -f downloaded.apk

echo ""
print_warning "Automatic download not available for this app."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BOLD}Please download manually (Takes 2 minutes):${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BOLD}STEP 1: Open APKPure${NC}"
echo ""
echo "  Click this link (or copy-paste into browser):"
echo -e "  ${CYAN}https://apkpure.com/search?q=$PACKAGE_NAME${NC}"
echo ""
echo -e "${BOLD}STEP 2: Download the APK${NC}"
echo ""
echo "  1. Click on the first search result (your app)"
echo "  2. Click the green 'Download APK' button"
echo "  3. Wait for download to complete"
echo "  4. The file will be in your Downloads folder"
echo ""
echo -e "${BOLD}STEP 3: Run the analysis${NC}"
echo ""
echo "  Copy and paste this command:"
echo -e "  ${GREEN}./detect-sdk-android.sh -s pspdfkit -s nutrient -f ~/Downloads/*.apk${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Offer to open browser
read -p "Open APKPure in your browser now? (y/n): " open_browser
if [[ $open_browser =~ ^[Yy]$ ]]; then
    open "https://apkpure.com/search?q=$PACKAGE_NAME" 2>/dev/null || \
    xdg-open "https://apkpure.com/search?q=$PACKAGE_NAME" 2>/dev/null || \
    print_info "Please open: https://apkpure.com/search?q=$PACKAGE_NAME"
    echo ""
    print_success "Browser opened!"
    echo ""
    print_info "After downloading from APKPure, run:"
    echo -e "  ${GREEN}./detect-sdk-android.sh -s pspdfkit -s nutrient -f ~/Downloads/*.apk${NC}"
    echo ""
fi

exit 1
