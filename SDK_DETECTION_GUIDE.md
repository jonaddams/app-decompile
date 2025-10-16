# iOS App SDK Detection Guide

A comprehensive guide for analyzing iOS apps to detect the presence of specific SDKs or libraries. This is useful for license compliance verification and security audits.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Tool Installation](#tool-installation)
3. [Authentication Setup](#authentication-setup)
4. [Downloading the App](#downloading-the-app)
5. [Extracting and Analyzing](#extracting-and-analyzing)
6. [Detection Methods](#detection-methods)
7. [Generating Reports](#generating-reports)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### System Requirements
- macOS (required for iOS app analysis)
- Homebrew package manager
- Apple ID account
- Terminal access
- Basic command line knowledge

### Legal Considerations
**IMPORTANT**: This guide is for legitimate defensive security purposes only:
- ✅ License compliance verification
- ✅ Security audits of apps you own or have permission to analyze
- ✅ Detecting unauthorized SDK usage by former customers
- ❌ Reverse engineering for malicious purposes
- ❌ Bypassing app protections or DRM

---

## Tool Installation

### 1. Install Homebrew (if not already installed)

```bash
# Check if Homebrew is installed
which brew

# If not installed, run:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install ipatool

`ipatool` is a command-line tool for downloading iOS apps from the App Store.

```bash
# Install via Homebrew
brew install ipatool

# Verify installation
ipatool --version
```

**Alternative**: If Homebrew installation fails, you can install from source:
```bash
# Install Go if needed
brew install go

# Install ipatool from source
go install github.com/majd/ipatool/cmd/ipatool@latest
```

### 3. Install Additional Utilities

Most macOS systems already have these, but verify:

```bash
# Check for required tools
which unzip strings otool plutil find grep

# If any are missing, they're typically part of Xcode Command Line Tools:
xcode-select --install
```

---

## Authentication Setup

### Step 1: Authenticate with Apple ID

```bash
# Login with your Apple ID
ipatool auth login --email your-apple-id@example.com
```

You'll be prompted for:
1. Your Apple ID password
2. Two-factor authentication code (if enabled)

**Security Notes**:
- ipatool stores credentials in your macOS Keychain
- Your password is never stored in plain text
- You can revoke access at any time

### Step 2: Verify Authentication

```bash
# Check authentication status
ipatool auth info
```

You should see output like:
```
email=your-apple-id@example.com name="Your Name" success=true
```

### Step 3: Handle Token Expiration

If you see "password token is expired" errors:

```bash
# Revoke current session
ipatool auth revoke

# Re-authenticate
ipatool auth login --email your-apple-id@example.com
```

---

## Downloading the App

### Step 1: Find the App

**Option A: From App Store URL**

If you have the App Store URL (e.g., `https://apps.apple.com/us/app/example-app/id1234567890`):

```bash
# Extract the app ID from the URL (the number after 'id')
# In this example: 1234567890
```

**Option B: Search by Name**

```bash
# Search for the app
ipatool search "App Name" --limit 10
```

Example output:
```json
[{
  "bundleID": "com.example.app",
  "id": 1234567890,
  "name": "Example App",
  "price": 0,
  "version": "1.2.3"
}]
```

Note the `bundleID` and `id` from the results.

### Step 2: Download the IPA

```bash
# Create a directory for your analysis
mkdir -p ~/app-analysis
cd ~/app-analysis

# Download using bundle ID
ipatool download -b com.example.app --purchase -o example-app.ipa

# OR download using app ID
ipatool download -i 1234567890 --purchase -o example-app.ipa
```

**Flags explained**:
- `-b`: Bundle identifier (package name)
- `-i`: App Store ID (numeric)
- `--purchase`: Automatically "purchase" free apps (adds to your account)
- `-o`: Output filename

**Note**: The `--purchase` flag will add free apps to your Apple ID account if not already purchased. For paid apps, you must already own them.

---

## Extracting and Analyzing

### Step 1: Extract the IPA

IPA files are just ZIP archives with a specific structure.

```bash
# Create extraction directory
mkdir -p extracted

# Extract the IPA
unzip -q example-app.ipa -d extracted

# View the structure
ls -la extracted/
```

Expected structure:
```
extracted/
├── Payload/
│   └── AppName.app/         # The actual app bundle
├── META-INF/                # Metadata
└── iTunesMetadata.plist     # App Store metadata
```

### Step 2: Navigate to the App Bundle

```bash
# List the app bundle
ls extracted/Payload/

# Enter the app bundle (name may vary)
cd "extracted/Payload/AppName.app"
```

### Step 3: Explore the App Structure

```bash
# View main contents
ls -la

# Common important files/folders:
# - AppName (executable binary)
# - Info.plist (app configuration)
# - Frameworks/ (embedded frameworks/SDKs)
# - Assets.car (compiled assets)
# - *.nib files (UI layouts)
```

---

## Detection Methods

### Method 1: Check Frameworks Directory

This is the **most reliable** method for detecting embedded SDKs.

```bash
# List all frameworks
ls -la Frameworks/

# Look for your SDK (case-insensitive)
ls Frameworks/ | grep -i "pspdfkit\|nutrient"
```

If your SDK is present, you'll see something like:
```
PSPDFKit.framework/
```

**Examine the framework**:
```bash
# View framework contents
ls -la Frameworks/PSPDFKit.framework/

# Check framework Info.plist
plutil -p Frameworks/PSPDFKit.framework/Info.plist

# Key fields to check:
# - CFBundleIdentifier (package name)
# - CFBundleShortVersionString (version)
# - CFBundleVersion (build number)
```

### Method 2: Check Dynamic Library Dependencies

The app binary lists all frameworks it links against:

```bash
# Go back to app bundle root
cd "extracted/Payload/AppName.app"

# List dynamic library dependencies
otool -L AppName

# Filter for your SDK
otool -L AppName | grep -i "pspdfkit\|nutrient"
```

Example output:
```
@rpath/PSPDFKit.framework/PSPDFKit (compatibility version 1.0.0, current version 1.0.0)
```

### Method 3: Search Binary Strings

Search for text strings within the binary:

```bash
# Search in main binary
strings AppName | grep -i "pspdfkit\|nutrient"

# Search in a framework binary
strings Frameworks/PSPDFKit.framework/PSPDFKit | grep -i "copyright\|pspdf"
```

### Method 4: Search All Files

Comprehensive file name and content search:

```bash
# Search for files with SDK name
find . -type f -iname "*pspdfkit*" -o -iname "*nutrient*"

# Search for bundle identifiers in plists
find . -name "*.plist" -exec plutil -p {} \; 2>/dev/null | grep -i "pspdfkit\|nutrient"
```

### Method 5: Check Framework Headers

If headers are included (development frameworks):

```bash
# List header files
ls Frameworks/PSPDFKit.framework/Headers/

# Check main header for version/copyright
cat Frameworks/PSPDFKit.framework/Headers/PSPDFKit.h | head -30
```

### Method 6: Calculate Framework Size

```bash
# Get framework size
du -sh Frameworks/PSPDFKit.framework/

# Compare to total app size
du -sh .
```

This helps determine how much of the app consists of your SDK.

---

## Generating Reports

### Quick Analysis Script

Save this as `analyze-sdk.sh`:

```bash
#!/bin/bash

# Usage: ./analyze-sdk.sh "SDK_NAME" "/path/to/extracted/Payload/AppName.app"

SDK_NAME="$1"
APP_PATH="$2"

echo "================================"
echo "SDK Detection Report"
echo "================================"
echo ""

# App Info
echo "## App Information"
cd "$APP_PATH"
APP_NAME=$(basename "$APP_PATH" .app)
echo "App Name: $APP_NAME"
echo "Bundle ID: $(plutil -extract CFBundleIdentifier raw Info.plist 2>/dev/null)"
echo "Version: $(plutil -extract CFBundleShortVersionString raw Info.plist 2>/dev/null)"
echo ""

# Framework Search
echo "## Framework Detection"
if [ -d "Frameworks" ]; then
    FOUND_FRAMEWORKS=$(ls Frameworks/ | grep -i "$SDK_NAME")
    if [ -n "$FOUND_FRAMEWORKS" ]; then
        echo "✅ FOUND: $SDK_NAME framework(s) detected"
        echo "$FOUND_FRAMEWORKS"

        for fw in $FOUND_FRAMEWORKS; do
            echo ""
            echo "### $fw Details:"
            FW_PATH="Frameworks/$fw"

            if [ -f "$FW_PATH/Info.plist" ]; then
                echo "Bundle ID: $(plutil -extract CFBundleIdentifier raw "$FW_PATH/Info.plist" 2>/dev/null)"
                echo "Version: $(plutil -extract CFBundleShortVersionString raw "$FW_PATH/Info.plist" 2>/dev/null)"
                echo "Build: $(plutil -extract CFBundleVersion raw "$FW_PATH/Info.plist" 2>/dev/null)"
            fi

            echo "Size: $(du -sh "$FW_PATH" | cut -f1)"
        done
    else
        echo "❌ NOT FOUND: No frameworks matching '$SDK_NAME'"
    fi
else
    echo "⚠️  No Frameworks directory found"
fi

echo ""

# Binary Dependencies
echo "## Binary Dependencies"
DEPS=$(otool -L "$APP_NAME" 2>/dev/null | grep -i "$SDK_NAME")
if [ -n "$DEPS" ]; then
    echo "✅ FOUND: Binary links to $SDK_NAME"
    echo "$DEPS"
else
    echo "❌ NOT FOUND: No binary dependencies on $SDK_NAME"
fi

echo ""
echo "================================"
```

**Usage**:
```bash
chmod +x analyze-sdk.sh
./analyze-sdk.sh "pspdfkit" "extracted/Payload/AppName.app"
```

---

## Troubleshooting

### Problem: "app not found" when downloading

**Solution**: The bundle ID might be wrong. Search first:
```bash
ipatool search "App Name" --limit 5
```

### Problem: "password token is expired"

**Solution**: Re-authenticate:
```bash
ipatool auth revoke
ipatool auth login --email your@email.com
```

### Problem: Can't download paid app

**Solution**: You must already own the app in your Apple ID account. ipatool can only download apps you have purchased.

### Problem: Two-factor authentication issues

**Solution**:
1. Make sure you're using an app-specific password if required
2. Generate one at: https://appleid.apple.com/account/manage
3. Use that password instead of your main password

### Problem: "Permission denied" when extracting

**Solution**:
```bash
# Remove old extraction and retry
rm -rf extracted
mkdir -p extracted
unzip -q app.ipa -d extracted
```

### Problem: Binary strings not readable

**Solution**: iOS binaries are often encrypted. Use these alternatives:
- Focus on framework Info.plist files
- Check headers if available
- Use `otool -L` for dependencies
- Look for the framework directory itself

### Problem: Can't find otool or other tools

**Solution**: Install Xcode Command Line Tools:
```bash
xcode-select --install
```

---

## Example: Complete Workflow

Here's a complete example from start to finish:

```bash
# 1. Create workspace
mkdir -p ~/sdk-analysis
cd ~/sdk-analysis

# 2. Authenticate
ipatool auth login --email your@email.com

# 3. Search for app
ipatool search "Data Collect Mobile" --limit 5

# 4. Download app (using bundle ID from search results)
ipatool download -b com.scenedoc.mobile.ios --purchase -o app.ipa

# 5. Extract
mkdir extracted
unzip -q app.ipa -d extracted

# 6. Navigate to app bundle
cd "extracted/Payload"
APP_DIR=$(ls)
cd "$APP_DIR"

# 7. Check for frameworks
ls -la Frameworks/ | grep -i "pspdfkit\|nutrient"

# 8. Check framework details
plutil -p Frameworks/PSPDFKit.framework/Info.plist | grep -E "CFBundle|Version"

# 9. Check binary dependencies
otool -L * | grep -i "pspdfkit\|nutrient"

# 10. Get framework size
du -sh Frameworks/PSPDFKit.framework/

# 11. Document findings
echo "SDK Found: PSPDFKit" > ../../analysis-report.txt
echo "Version: $(plutil -extract CFBundleShortVersionString raw Frameworks/PSPDFKit.framework/Info.plist)" >> ../../analysis-report.txt
echo "Size: $(du -sh Frameworks/PSPDFKit.framework/ | cut -f1)" >> ../../analysis-report.txt
```

---

## Additional Resources

### Useful Commands

```bash
# Find all .framework directories
find . -name "*.framework" -type d

# List all dynamic libraries
otool -L AppName | grep -v "System\|usr/lib"

# Search for specific strings in all files
grep -r "pspdfkit" . 2>/dev/null

# Get app signing info
codesign -dv --verbose=4 AppName

# Extract specific plist values
plutil -extract CFBundleIdentifier raw Info.plist
```

### Understanding App Bundle Structure

```
AppName.app/
├── AppName                           # Main executable
├── Info.plist                        # App metadata
├── PkgInfo                          # Package type info
├── _CodeSignature/                  # Code signing data
├── Assets.car                       # Compiled asset catalog
├── Frameworks/                      # Embedded frameworks
│   ├── YourSDK.framework/
│   │   ├── YourSDK                 # Framework binary
│   │   ├── Info.plist              # Framework metadata
│   │   ├── Headers/                # Public headers (if included)
│   │   └── Resources/              # Framework resources
├── PlugIns/                        # App extensions
├── Base.lproj/                     # Localized resources
└── *.nib / *.storyboard            # UI files
```

### SDK Detection Checklist

- [ ] Framework directory exists
- [ ] Framework Info.plist has correct bundle ID
- [ ] Binary has dynamic library dependency
- [ ] Framework binary exists and has correct size
- [ ] Headers mention SDK (if present)
- [ ] Version matches expected range
- [ ] Build date is recent
- [ ] No "Nutrient" rebrand detected (if checking for old PSPDFKit)

---

## Security and Privacy

### Data Handling
- IPA files may contain sensitive information
- Do not share extracted app contents publicly
- Delete analysis files when done:
  ```bash
  rm -rf ~/sdk-analysis
  ```

### Responsible Disclosure
If you discover unauthorized SDK usage:
1. Document findings thoroughly
2. Contact the developer/company directly first
3. Provide reasonable time to respond
4. Follow your company's legal procedures
5. Consult with legal counsel if needed

---

## Conclusion

This guide provides a systematic approach to detecting SDK presence in iOS applications. The combination of framework inspection, binary analysis, and string searching provides high confidence in detection results.

For questions or issues with this guide, consult the official documentation:
- ipatool: https://github.com/majd/ipatool
- otool: `man otool`
- Apple Developer Documentation: https://developer.apple.com/documentation/

---

**Last Updated**: 2025-01-15
**Version**: 1.0
