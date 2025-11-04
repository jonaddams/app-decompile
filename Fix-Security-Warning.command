#!/bin/bash

# SDK Analyzer - Security Warning Fix
# Double-click this file to remove the security warning

cd "$(dirname "$0")"

clear
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         SDK Analyzer - Security Warning Fix                    ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "This will remove the macOS security warning from SDK Analyzer.app"
echo ""

# Find the app
if [ -d "SDK Analyzer.app" ]; then
    echo "✓ Found SDK Analyzer.app"
    echo ""
    echo "Removing security warning..."
    xattr -cr "SDK Analyzer.app"

    echo "✓ Done!"
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║  Success! You can now use SDK Analyzer.app                     ║"
    echo "║  Close this window and double-click SDK Analyzer.app           ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
else
    echo "❌ Error: Could not find SDK Analyzer.app in this folder"
    echo ""
    echo "Please make sure this script is in the same folder as SDK Analyzer.app"
fi

echo ""
echo "Press any key to close..."
read -n 1 -s
