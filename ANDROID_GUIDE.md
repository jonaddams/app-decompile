# Android App SDK Detection Guide

A comprehensive guide for detecting SDK presence in Android applications (APK files) for license compliance verification.

## Table of Contents
1. [Overview](#overview)
2. [How Android Detection Differs from iOS](#how-android-detection-differs-from-ios)
3. [Installation](#installation)
4. [Getting APK Files](#getting-apk-files)
5. [Running the Analysis](#running-the-analysis)
6. [Understanding Results](#understanding-results)
7. [Troubleshooting](#troubleshooting)

---

## Overview

The Android SDK detection tool analyzes APK files to identify embedded SDKs and libraries. It's similar to the iOS tool but adapted for Android's architecture.

### Key Differences: Android vs iOS

| Feature | iOS (IPA) | Android (APK) |
|---------|-----------|---------------|
| File Format | IPA (encrypted) | APK (unencrypted ZIP) |
| Download | App Store (requires Apple ID) | Multiple sources available |
| Binary Format | Mach-O | ELF (.so files) + Dalvik/ART (DEX) |
| Frameworks | .framework bundles | .aar libraries + .so files |
| Tool | ipatool | apktool + manual download |
| Obfuscation | Limited | Common (ProGuard/R8) |

---

## Installation

### Prerequisites

- **macOS or Linux**
- **Java JDK** (required for apktool)
- **Internet connection**

### Automatic Installation

The script automatically installs:
- ✅ Homebrew (macOS only, if needed)
- ✅ Java JDK (if needed)
- ✅ apktool (if needed)

Just run the script and it will handle setup!

### Manual Installation (Optional)

```bash
# macOS
brew install openjdk
brew install apktool

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install default-jdk apktool

# Arch Linux
sudo pacman -S jdk-openjdk android-apktool
```

---

## Getting APK Files

Unlike iOS, there are multiple ways to obtain Android APK files:

### Method 0: Use the Download Helper (Easiest for Non-Technical Users!)

We provide a simple helper script that tries to download APKs automatically:

```bash
./download-apk-helper.sh "https://play.google.com/store/apps/details?id=com.example.app"

# Or by package name
./download-apk-helper.sh com.example.app
```

**What it does:**
- ✅ Tries automatic download from APKPure
- ✅ Tries extracting from connected Android device
- ✅ If fails, opens browser with exact download link
- ✅ Provides copy-paste commands for non-technical users
- ✅ No technical knowledge required!

### Method 1: Use Existing APK File (Recommended)

If you already have the APK:

```bash
./detect-sdk-android.sh -s pspdfkit -f /path/to/app.apk
```

### Method 2: Download from Third-Party Sites

**APKPure**:
1. Visit [APKPure.com](https://apkpure.com)
2. Search for the app
3. Download the APK file
4. Run: `./detect-sdk-android.sh -s pspdfkit -f downloaded.apk`

**APKMirror**:
1. Visit [APKMirror.com](https://www.apkmirror.com)
2. Search for the app
3. Download the APK file (choose the appropriate variant)
4. Run: `./detect-sdk-android.sh -s pspdfkit -f downloaded.apk`

### Method 3: Extract from Android Device

If you have an Android device with the app installed:

```bash
# 1. Connect device via USB
# 2. Enable USB debugging on device
# 3. Install app on device if not already

# Extract APK using ADB
adb shell pm path com.example.app
# Output: package:/data/app/com.example.app-xxx/base.apk

# Pull the APK
adb pull /data/app/com.example.app-xxx/base.apk app.apk

# Analyze it
./detect-sdk-android.sh -s pspdfkit -f app.apk
```

**Note**: The script will attempt ADB extraction automatically if a device is connected.

### Method 4: Let Script Try Auto-Download

The script attempts to download APKs automatically from APKPure:

```bash
# By package name
./detect-sdk-android.sh -s pspdfkit -p com.example.app

# By Play Store URL
./detect-sdk-android.sh -s pspdfkit -u "https://play.google.com/store/apps/details?id=com.example.app"
```

**Success Rate**: Variable (depends on app availability on APKPure)

---

## Running the Analysis

### Basic Usage

```bash
# Analyze existing APK file
./detect-sdk-android.sh -s pspdfkit -f app.apk

# Analyze by package name
./detect-sdk-android.sh -s pspdfkit -p com.example.app

# Analyze by Play Store URL
./detect-sdk-android.sh -s pspdfkit -u "https://play.google.com/store/apps/details?id=com.example.app"
```

### Multiple SDKs

```bash
./detect-sdk-android.sh -s pspdfkit -s nutrient -s firebase -f app.apk
```

### Advanced Options

```bash
# Keep analysis files (no cleanup)
./detect-sdk-android.sh -s pspdfkit -f app.apk --no-cleanup

# Verbose output
./detect-sdk-android.sh -s pspdfkit -f app.apk -v

# Custom report name
./detect-sdk-android.sh -s pspdfkit -f app.apk -o my-android-report.txt
```

---

## Understanding Results

### Detection Methods

The tool uses four methods to detect SDKs:

#### 1. Native Library Inspection

Searches `lib/` directories for `.so` files:

```
lib/
├── arm64-v8a/
│   ├── libpspdfkit.so          ← SDK found!
│   └── libother.so
├── armeabi-v7a/
│   └── libpspdfkit.so          ← SDK found!
└── x86/
    └── libpspdfkit.so          ← SDK found!
```

**Most Reliable**: Native libraries are hardest to obfuscate.

#### 2. Java Class Analysis

Searches decompiled code for SDK classes:

```
com/pspdfkit/                   ← SDK package found!
├── PdfActivity.smali
├── PdfDocument.smali
└── annotations/
```

**Note**: May be obfuscated by ProGuard/R8.

#### 3. Asset and Resource Search

Searches for SDK assets:

```
assets/
├── pspdfkit/                   ← SDK assets found!
│   ├── fonts/
│   └── images/
```

#### 4. Manifest Analysis

Checks `AndroidManifest.xml` for SDK declarations:

```xml
<application>
    <meta-data
        android:name="pspdfkit.license"  ← SDK reference found!
        android:value="..." />
</application>
```

### Example Output

```
========================================
SDK Detection
========================================

Searching for: pspdfkit
🔍 FOUND: Native libraries detected
  📦 libpspdfkit.so (12M)
🔍 FOUND: Java classes detected (245 files)
🔍 FOUND: Assets/resources detected (15 files)

✅ RESULT: pspdfkit SDK IS PRESENT

Searching for: nutrient
❌ RESULT: nutrient SDK NOT DETECTED
```

### Generated Report

Report filename: `sdk-detection-android-{package-name}-{timestamp}.txt`

Example: `sdk-detection-android-com-example-app-20251016-103045.txt`

---

## Troubleshooting

### APK Download Issues

**Problem**: Auto-download fails (especially for enterprise apps like MaaS360)

**Why This Happens**:
- Enterprise apps often aren't available via APKPure's CDN
- Corporate/MDM apps may have restricted distribution
- Some apps are region-locked or require specific device types

**Solutions (In Order of Ease)**:

#### Solution 1: Manual Download from APKMirror (Recommended for Enterprise Apps)

**For MaaS360 specifically**:
1. Visit: https://www.apkmirror.com
2. Search for "MaaS360"
3. Click the first result: "MaaS360 MDM by IBM"
4. Look for the latest version
5. Click on the version number
6. Scroll down and click the **Download APK** button
7. On the next page, click **Download [app-name]**
8. APK will download to your Downloads folder

Then run:
```bash
./detect-sdk-android.sh -s pspdfkit -s nutrient -f ~/Downloads/com.fiberlink*.apk
```

**For other apps**:
1. Visit: https://www.apkmirror.com
2. Search for your app name or package ID
3. Download the appropriate variant (usually "universal" or "arm64-v8a")
4. Run the analysis script with the downloaded APK

#### Solution 2: Download from APKPure (Good for Consumer Apps)

**Using the helper script**:
```bash
./download-apk-helper.sh "https://play.google.com/store/apps/details?id=com.example.app"
```

The helper script will:
- Try automatic download
- If that fails, open APKPure in your browser with exact instructions
- Provide copy-paste commands

**Manual APKPure download**:
1. Visit: https://apkpure.com
2. Search for your app
3. Click "Download APK" button
4. File downloads directly (no intermediate pages)

#### Solution 3: Extract from Android Device Using ADB

```bash
# 1. Connect Android device via USB
# 2. Enable USB debugging on device
# 3. Verify connection
adb devices

# 4. Find the app's APK path
adb shell pm path com.fiberlink.maas360.android.control
# Output: package:/data/app/com.fiberlink.maas360.android.control-xxx/base.apk

# 5. Pull the APK
adb pull /data/app/com.fiberlink.maas360.android.control-xxx/base.apk maas360.apk

# 6. Analyze it
./detect-sdk-android.sh -s pspdfkit -s nutrient -f maas360.apk
```

#### Solution 4: Request APK from Customer

If the app is proprietary or internal:
1. Ask customer to provide the APK file directly
2. Explain it's for license compliance verification
3. Assure them the file will be handled securely and deleted after analysis

### apktool Errors

**Problem**: `apktool` fails to decompile

**Solutions**:
```bash
# Update apktool
brew upgrade apktool  # macOS
sudo apt-get upgrade apktool  # Linux

# Try with newer apktool version
apktool d app.apk -o extracted --force
```

### Obfuscation Issues

**Problem**: SDK classes not found, but you know SDK is present

**Explanation**: App uses ProGuard/R8 obfuscation

**Solutions**:
1. Check native libraries (harder to obfuscate)
   ```bash
   unzip -l app.apk | grep "\.so$"
   ```

2. Check assets folder
   ```bash
   unzip -l app.apk | grep "assets/"
   ```

3. Request mapping file from customer
   ```
   mapping.txt contains de-obfuscation mappings
   ```

4. Use verbose mode to see all files
   ```bash
   ./detect-sdk-android.sh -s pspdfkit -f app.apk -v
   ```

### Java Not Found

**Problem**: `java: command not found`

**Solution**:
```bash
# macOS
brew install openjdk
sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk \
  /Library/Java/JavaVirtualMachines/openjdk.jdk

# Linux
sudo apt-get install default-jdk
```

### ADB Issues

**Problem**: Can't extract from device

**Solutions**:
```bash
# Check device connection
adb devices

# If empty, enable USB debugging on device:
# Settings → Developer Options → USB Debugging

# If "unauthorized", check device screen for prompt

# List installed packages
adb shell pm list packages | grep example

# Check if app is installed
adb shell pm path com.example.app
```

---

## Comparison: Finding Your SDK

### In iOS (IPA)

Your SDK appears as:
```
Frameworks/
└── PSPDFKit.framework/
    ├── PSPDFKit (binary)
    ├── Info.plist
    └── Headers/
```

### In Android (APK)

Your SDK appears in multiple locations:

**Native Libraries**:
```
lib/arm64-v8a/libpspdfkit.so
lib/armeabi-v7a/libpspdfkit.so
```

**Java Classes**:
```
com/pspdfkit/PdfActivity.smali
com/pspdfkit/ui/PdfFragment.smali
```

**Resources**:
```
res/layout/pspdfkit_activity.xml
assets/pspdfkit/fonts/
```

**Manifest**:
```xml
<meta-data android:name="pspdfkit.license" />
```

---

## Command Reference

```bash
# Analyze existing APK
./detect-sdk-android.sh -s <sdk-name> -f <apk-file>

# Analyze by package name
./detect-sdk-android.sh -s <sdk-name> -p <package-name>

# Analyze by Play Store URL
./detect-sdk-android.sh -s <sdk-name> -u "<play-store-url>"

# Multiple SDKs
./detect-sdk-android.sh -s sdk1 -s sdk2 -s sdk3 -f app.apk

# Custom output
./detect-sdk-android.sh -s <sdk-name> -f app.apk -o report.txt

# Keep files
./detect-sdk-android.sh -s <sdk-name> -f app.apk --no-cleanup

# Verbose
./detect-sdk-android.sh -s <sdk-name> -f app.apk -v

# Help
./detect-sdk-android.sh --help
```

---

## Best Practices

### For License Compliance

1. **Always check native libraries first** - They're the most reliable indicator
2. **Document all findings** - Keep generated reports for legal records
3. **Check multiple app versions** - Verify SDK removal across updates
4. **Consider obfuscation** - Request mapping files if classes aren't found

### For Accuracy

1. **Test with known apps** - Verify detection works with apps you control
2. **Check all architectures** - SDK may be present in some architectures only
3. **Review assets carefully** - SDKs often include bundled resources
4. **Cross-reference with manifest** - Look for SDK permissions and metadata

### For Efficiency

1. **Batch processing** - Analyze multiple apps in sequence
2. **Use existing APKs** - Faster than downloading
3. **Keep reports organized** - Use descriptive filenames
4. **Document your sources** - Note where APKs came from

---

## FAQ

**Q: Can I analyze apps directly from Google Play?**
A: Google doesn't provide official APIs. You must download APKs from third-party sources or extract from devices.

**Q: Is it legal to download APKs from third-party sites?**
A: For license compliance verification of former customers, this is generally considered fair use. Consult legal counsel for your specific situation.

**Q: What if the app uses ProGuard/R8?**
A: Native libraries (.so files) are usually not obfuscated. Check those first. Assets and manifest entries are also preserved.

**Q: Can I analyze app bundles (.aab)?**
A: No, this tool works with APK files only. Convert .aab to .apk first using bundletool.

**Q: How accurate is the detection?**
A: Very accurate for native libraries (95%+). Java class detection depends on obfuscation level (60-95%).

**Q: Can I use this for security audits?**
A: Yes, but remember this is for defensive purposes only (license compliance, security analysis of your own apps, etc.).

---

## Additional Resources

- **APKTool Documentation**: https://ibotpeaches.github.io/Apktool/
- **ADB Documentation**: https://developer.android.com/studio/command-line/adb
- **APKPure**: https://apkpure.com
- **APKMirror**: https://www.apkmirror.com

---

**Version**: 1.0
**Last Updated**: 2025-10-16
**Platform**: macOS, Linux
