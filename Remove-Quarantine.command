#!/bin/bash

# SDK Analyzer - Remove Quarantine Helper
# Double-click this file to remove macOS quarantine from SDK Analyzer

cd "$(dirname "$0")"

clear
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         SDK Analyzer - Remove Quarantine                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "This will remove macOS security restrictions from SDK Analyzer."
echo ""

# Find the app
if [ -d "SDK Analyzer.app" ]; then
    echo "✓ Found SDK Analyzer.app"
    echo ""
    echo "Removing quarantine attributes..."
    xattr -cr "SDK Analyzer.app"

    # Also remove from scripts to be thorough
    xattr -cr detect-sdk-ios.sh 2>/dev/null
    xattr -cr detect-sdk-android.sh 2>/dev/null

    echo "✓ Done!"
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║  Success! SDK Analyzer is ready to use.                       ║"
    echo "║  Close this window and double-click SDK Analyzer.app          ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
else
    echo "❌ Error: Could not find SDK Analyzer.app in this folder"
    echo ""
    echo "Please make sure this script is in the same folder as SDK Analyzer.app"
fi

echo ""
echo "Press any key to close..."
read -n 1 -s
