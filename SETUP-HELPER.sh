#!/bin/bash

################################################################################
# SDK Analyzer Setup Helper
# Automatically removes macOS quarantine and verifies installation
################################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "${BOLD}${BLUE}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         SDK Analyzer Setup Helper                              ║"
echo "║         Fixing macOS Security Warnings                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

# Find SDK Analyzer.app
APP_NAME="SDK Analyzer.app"
APP_PATH=""

# Check current directory
if [ -d "$APP_NAME" ]; then
    APP_PATH="$PWD/$APP_NAME"
elif [ -d "../$APP_NAME" ]; then
    APP_PATH="$PWD/../$APP_NAME"
elif [ -d "~/Desktop/$APP_NAME" ]; then
    APP_PATH="$HOME/Desktop/$APP_NAME"
elif [ -d "~/Downloads/$APP_NAME" ]; then
    APP_PATH="$HOME/Downloads/$APP_NAME"
fi

# If not found, ask user
if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo -e "${YELLOW}⚠️  Could not find 'SDK Analyzer.app' automatically${NC}"
    echo ""
    echo "Please drag and drop the 'SDK Analyzer.app' file here and press Enter:"
    read -r USER_PATH

    # Remove quotes if present
    USER_PATH="${USER_PATH//\'/}"
    USER_PATH="${USER_PATH//\"/}"

    if [ -d "$USER_PATH" ]; then
        APP_PATH="$USER_PATH"
    else
        echo -e "${RED}❌ Error: Could not find app at: $USER_PATH${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓ Found app at: $APP_PATH${NC}\n"

# Check for quarantine attribute
echo -e "${BLUE}Checking for quarantine attribute...${NC}"
QUARANTINE=$(xattr -l "$APP_PATH" 2>/dev/null | grep "com.apple.quarantine" || true)

if [ -n "$QUARANTINE" ]; then
    echo -e "${YELLOW}⚠️  Quarantine attribute found (this causes the security warning)${NC}"
    echo ""
    echo -e "${BLUE}Removing quarantine attribute...${NC}"

    # Remove quarantine
    xattr -cr "$APP_PATH"

    # Verify it's gone
    QUARANTINE_CHECK=$(xattr -l "$APP_PATH" 2>/dev/null | grep "com.apple.quarantine" || true)

    if [ -z "$QUARANTINE_CHECK" ]; then
        echo -e "${GREEN}✅ Quarantine attribute removed successfully!${NC}"
    else
        echo -e "${RED}❌ Failed to remove quarantine attribute${NC}"
        echo ""
        echo "Please try running with sudo:"
        echo "  sudo xattr -cr \"$APP_PATH\""
        exit 1
    fi
else
    echo -e "${GREEN}✓ No quarantine attribute found${NC}"
fi

# Check app signature
echo ""
echo -e "${BLUE}Checking app signature...${NC}"
SIGNATURE=$(codesign -dv "$APP_PATH" 2>&1 || true)

if echo "$SIGNATURE" | grep -q "Signature=adhoc"; then
    echo -e "${YELLOW}⚠️  App has ad-hoc signature (expected for unsigned apps)${NC}"
elif echo "$SIGNATURE" | grep -q "code object is not signed at all"; then
    echo -e "${YELLOW}⚠️  App is not code-signed${NC}"
else
    echo -e "${GREEN}✓ App signature checked${NC}"
fi

# Check Homebrew (for iOS analysis)
echo ""
echo -e "${BLUE}Checking for Homebrew (needed for iOS analysis)...${NC}"
if command -v brew &> /dev/null; then
    BREW_VERSION=$(brew --version | head -1)
    echo -e "${GREEN}✓ Homebrew found: $BREW_VERSION${NC}"

    # Check for ipatool
    if command -v ipatool &> /dev/null; then
        IPATOOL_VERSION=$(ipatool --version 2>&1 | head -1)
        echo -e "${GREEN}✓ ipatool found: $IPATOOL_VERSION${NC}"

        # Check authentication
        if ipatool auth info &> /dev/null; then
            AUTH_EMAIL=$(ipatool auth info 2>&1 | grep -o 'email=[^ ]*' | cut -d= -f2 || echo "unknown")
            echo -e "${GREEN}✓ ipatool authenticated: $AUTH_EMAIL${NC}"
        else
            echo -e "${YELLOW}⚠️  ipatool not authenticated (app will prompt when needed)${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  ipatool not installed (app will guide you through setup)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Homebrew not installed (needed for iOS analysis)${NC}"
    echo ""
    echo "To install Homebrew, run:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
fi

# Summary
echo ""
echo -e "${BOLD}${GREEN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    Setup Complete! ✅                          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${GREEN}✓ Security warnings should be resolved${NC}"
echo -e "${GREEN}✓ You can now double-click 'SDK Analyzer.app' to use it${NC}"
echo ""

# Offer to open the app
echo -e "${BLUE}Would you like to open SDK Analyzer now? (y/n)${NC}"
read -r OPEN_APP

if [[ $OPEN_APP =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BLUE}Opening SDK Analyzer...${NC}"
    open "$APP_PATH"
    echo -e "${GREEN}✓ App launched!${NC}"
fi

echo ""
echo -e "${BOLD}If you still see security warnings:${NC}"
echo "1. Go to System Settings → Privacy & Security"
echo "2. Scroll down and click 'Open Anyway' next to SDK Analyzer"
echo "3. Or contact your IT administrator"
echo ""
echo -e "${GREEN}Thank you for using SDK Analyzer! 🎉${NC}"
