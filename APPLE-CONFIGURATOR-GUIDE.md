# Using Apple Configurator 2 to Extract iOS IPAs

## Overview

Apple Configurator 2 is a free Mac app that allows you to extract IPA files from iOS apps without needing ipatool. This works even while ipatool authentication is broken.

## Prerequisites

- Mac computer (macOS 10.15 or later)
- iOS device (iPhone or iPad)
- USB cable to connect device to Mac
- Apple ID (same one used on the iOS device)

## Installation

1. **Install Apple Configurator 2** (Free from Mac App Store)
   - Open Mac App Store
   - Search for "Apple Configurator 2"
   - Click "Get" or "Install"
   - Or use this direct link: https://apps.apple.com/us/app/apple-configurator/id1037126344

2. **First Launch Setup**
   - Open Apple Configurator 2
   - Sign in with your Apple ID when prompted
   - Grant necessary permissions if asked

## How to Extract an IPA File

### Step 1: Install the Target App on Your iPhone

1. On your iPhone, open the App Store
2. Search for and download the app you want to analyze
3. Let it fully install (you can delete it later)

### Step 2: Connect iPhone to Mac

1. Connect your iPhone to your Mac using a USB cable
2. Unlock your iPhone
3. If prompted "Trust This Computer?", tap "Trust"
4. Enter your iPhone passcode if asked

### Step 3: Download App via Apple Configurator

1. Open Apple Configurator 2
2. Your iPhone should appear in the main window
3. Click on your device icon
4. Go to: **Actions** → **Add** → **Apps...**
5. Sign in with your Apple ID if prompted
6. In the app selection window:
   - You'll see all apps available in the App Store
   - Search for the target app by name
7. Select the app and click "Add"

**Important:** Even if the app is already installed on your iPhone, Apple Configurator will download a fresh copy to your Mac.

### Step 4: Locate the Downloaded IPA

The IPA file is temporarily stored in this location:

```
~/Library/Group Containers/K36BKF7T3D.group.com.apple.configurator/Library/Caches/Assets/TemporaryItems/MobileApps/
```

**Quick way to open this folder:**

```bash
open ~/Library/Group\ Containers/K36BKF7T3D.group.com.apple.configurator/Library/Caches/Assets/TemporaryItems/MobileApps/
```

Or use Finder:
1. In Finder, press `Cmd + Shift + G`
2. Paste: `~/Library/Group Containers/K36BKF7T3D.group.com.apple.configurator/Library/Caches/Assets/TemporaryItems/MobileApps/`
3. Press Enter

### Step 5: Copy the IPA Before It Gets Deleted

⚠️ **Important:** Apple Configurator automatically deletes IPAs from this cache folder after a while.

**Copy the IPA to a permanent location immediately:**

```bash
# Create a directory for extracted IPAs
mkdir -p ~/Desktop/extracted-ipas

# Copy the IPA (replace with actual filename)
cp ~/Library/Group\ Containers/K36BKF7T3D.group.com.apple.configurator/Library/Caches/Assets/TemporaryItems/MobileApps/*.ipa ~/Desktop/extracted-ipas/
```

### Step 6: Analyze the IPA with SDK Analyzer

Now you can analyze the extracted IPA file using the SDK detection script:

**Option A: Using the Command Line Script**

```bash
cd /path/to/sdk-analyzer

# Extract the IPA manually
mkdir -p analysis-temp
unzip ~/Desktop/extracted-ipas/YourApp.ipa -d analysis-temp/

# Find the app bundle
APP_BUNDLE=$(find analysis-temp/Payload -name "*.app" -type d | head -1)

# Analyze frameworks
ls "$APP_BUNDLE/Frameworks/"

# Check for specific SDK
ls "$APP_BUNDLE/Frameworks/" | grep -i "pspdfkit\|nutrient"
```

**Option B: Modify detect-sdk-ios.sh to Accept Local IPA**

We can update your script to support analyzing a local IPA file instead of downloading from App Store.

## Helper Script for Quick Extraction

Save this as `extract-ipa.sh` in your SDK Analyzer folder:

```bash
#!/bin/bash

# Extract IPA from Apple Configurator cache
# Usage: ./extract-ipa.sh [app-name]

set -e

CACHE_DIR=~/Library/Group\ Containers/K36BKF7T3D.group.com.apple.configurator/Library/Caches/Assets/TemporaryItems/MobileApps
OUTPUT_DIR=~/Desktop/extracted-ipas

mkdir -p "$OUTPUT_DIR"

echo "Looking for IPAs in Apple Configurator cache..."
echo ""

if [ -d "$CACHE_DIR" ]; then
    IPA_COUNT=$(ls "$CACHE_DIR"/*.ipa 2>/dev/null | wc -l | tr -d ' ')

    if [ "$IPA_COUNT" -eq 0 ]; then
        echo "❌ No IPAs found in cache."
        echo ""
        echo "Make sure to:"
        echo "1. Open Apple Configurator 2"
        echo "2. Connect your iPhone"
        echo "3. Go to Actions → Add → Apps"
        echo "4. Select and add the app you want to analyze"
        exit 1
    fi

    echo "✅ Found $IPA_COUNT IPA(s):"
    echo ""
    ls -lh "$CACHE_DIR"/*.ipa
    echo ""

    # Copy all IPAs to output directory
    cp "$CACHE_DIR"/*.ipa "$OUTPUT_DIR/"

    echo "✅ Copied IPA(s) to: $OUTPUT_DIR"
    echo ""

    # List copied files
    echo "Extracted IPAs:"
    ls -lh "$OUTPUT_DIR"/*.ipa

else
    echo "❌ Apple Configurator cache directory not found."
    echo ""
    echo "This means Apple Configurator 2 hasn't been used yet."
    echo "Please use Apple Configurator 2 to download an app first."
    exit 1
fi
```

Make it executable:
```bash
chmod +x extract-ipa.sh
```

## Troubleshooting

### "Trust This Computer" Doesn't Appear
- Disconnect and reconnect your iPhone
- Try a different USB cable
- Restart both your Mac and iPhone

### Can't Find the IPA File
- The IPA might have been auto-deleted
- Try the download process again
- Run the `extract-ipa.sh` helper script immediately after downloading

### "Sign in Required" in Apple Configurator
- You need to sign in with the same Apple ID used on your iPhone
- Or use an Apple ID that has purchased/downloaded the app before

### App Doesn't Appear in Apple Configurator
- Make sure you're searching in the "Add Apps" dialog
- Some enterprise or beta apps might not be available
- The app must be available in your region's App Store

## Advantages Over ipatool

✅ **Works right now** - Not affected by Apple's authentication changes
✅ **Official Apple tool** - Legitimate and reliable
✅ **Free** - No cost, included with macOS
✅ **Simple** - GUI-based, no command line needed
✅ **Gets latest versions** - Always downloads the current App Store version

## Limitations

⚠️ **Requires physical device** - Must have an iPhone/iPad
⚠️ **Manual process** - Can't automate bulk downloads
⚠️ **App must be available** - Can't download apps not in your region
⚠️ **Temporary cache** - Must copy IPAs immediately

## Next Steps

Once you have the IPA file, you can:

1. **Analyze it manually:**
   ```bash
   unzip YourApp.ipa -d extracted/
   ls extracted/Payload/*.app/Frameworks/
   ```

2. **Use our detect-sdk-ios.sh with modifications** (we can add support for local IPAs)

3. **Use the Android method** if analyzing Android apps (that still works!)

## Need Help?

If you encounter issues:
1. Check the Troubleshooting section above
2. Verify your iPhone is connected and trusted
3. Make sure you're signed in to Apple Configurator with your Apple ID
4. Try with a free app first to test the process

---

**Created:** February 16, 2026
**Purpose:** Workaround for broken ipatool authentication
**Status:** ✅ Working solution
