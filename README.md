# iOS & Android App SDK Detection Tool

A comprehensive toolkit for detecting SDK presence in iOS and Android applications for license compliance verification and security audits.

## 🎯 Purpose

This tool helps you verify whether former customers have removed your SDK from their applications, ensuring license compliance. It's designed for legitimate defensive security purposes only.

## 📦 What's Included

### iOS Detection
1. **`detect-sdk.sh`** - Automated iOS detection script
2. **`GETTING_STARTED.md`** - **👉 START HERE** - Simple guide for non-technical users
3. **`SDK_DETECTION_GUIDE.md`** - Comprehensive iOS guide
4. **`USAGE_EXAMPLES.md`** - Real-world usage examples

### Android Detection
1. **`detect-sdk-android.sh`** - **🆕 Automated Android detection script**
2. **`ANDROID_GUIDE.md`** - **🆕 Comprehensive Android guide**

### General
1. **`README.md`** - This file (overview)
2. **`NON_TECHNICAL_QUICKSTART.txt`** - Printable cheat sheet

## ⚡ Quick Start

### iOS Apps

> ⚠️ **Note:** ipatool authentication is currently broken (Apple API change, Jan 2026). Use the Apple Configurator 2 method below instead. See [issue #437](https://github.com/majd/ipatool/issues/437).

**Required: Install Apple Configurator 2 and fswatch**
```bash
# Install fswatch (required — polling fallback does not work reliably)
brew install fswatch

# Install Apple Configurator 2 from the Mac App Store
open "macappstore://apps.apple.com/us/app/apple-configurator/id1037126344"
```

**Step 1: Start the IPA watcher** (leave this running in a terminal)
```bash
./watch-and-extract-ipa.sh
```

**Step 2: Download the app via Apple Configurator 2**
1. Connect your iPhone via USB and open Apple Configurator 2
2. Click your device → **Actions → Add → Apps...**
3. Search for and select the app → click **Add**
4. The watcher automatically copies the IPA to `~/Desktop/extracted-ipas/`

**Step 3: Analyze**
```bash
# List all frameworks
./detect-sdk-ios.sh --local-ipa ~/Desktop/extracted-ipas/YourApp.ipa

# Search for specific SDKs
./detect-sdk-ios.sh -s pspdfkit -s nutrient --local-ipa ~/Desktop/extracted-ipas/YourApp.ipa
```

See [QUICK-START-APPLE-CONFIGURATOR.md](QUICK-START-APPLE-CONFIGURATOR.md) for the full guide.

### Android Apps

```bash
# Make script executable (first time only)
chmod +x detect-sdk-android.sh

# Analyze existing APK file
./detect-sdk-android.sh -s pspdfkit -s nutrient -f /path/to/app.apk

# Analyze XAPK file (automatically extracts and merges split APKs)
./detect-sdk-android.sh -s pspdfkit -s nutrient -f app.xapk

# Or by package name (attempts auto-download)
./detect-sdk-android.sh -s pspdfkit -p com.example.app

# Or by Play Store URL
./detect-sdk-android.sh -s pspdfkit -u "https://play.google.com/store/apps/details?id=com.example.app"
```

**First time?** The script automatically installs Java and apktool!
**XAPK Support:** Download from APKPure and the script handles extraction automatically!

### Check Results

Reports are automatically generated with unique names:

**iOS**: `sdk-detection-com-example-app-20251015-153416.txt`
**Android**: `sdk-detection-android-com-example-app-20251015-153416.txt`

## 📊 Platform Comparison

| Feature | iOS | Android |
|---------|-----|---------|
| **Download Source** | Apple Configurator 2 (iPhone required) | APK/XAPK from multiple sources |
| **Auto-Download** | ❌ ipatool broken (Jan 2026) | ⚠️ Partial (APKPure) |
| **Manual Download** | ✅ Via Apple Configurator 2 | ✅ Easy (APKPure, APKMirror) |
| **XAPK Support** | N/A | ✅ Automatic extraction & merging |
| **Device Extract** | ✅ Via Apple Configurator 2 | ✅ Yes (via ADB) |
| **SDK Detection** | Framework bundles | Native libs + Java classes |
| **Obfuscation** | Rare | Common (ProGuard/R8) |
| **Accuracy** | 95%+ | 90%+ (95%+ for native libs) |

**Recommendation**:
- **iOS**: Use Apple Configurator 2 + `watch-and-extract-ipa.sh` (ipatool currently broken)
- **Android**: Download XAPK from APKPure - automatic extraction! (most reliable)

## 💡 Smart URL Handling

The tools automatically handle URLs with query parameters, so you can paste them directly:

**iOS**:
✅ `https://apps.apple.com/us/app/app-name/id1234567890`
✅ `https://apps.apple.com/us/app/app-name/id1234567890?l=es-MX`

**Android**:
✅ `https://play.google.com/store/apps/details?id=com.example.app`
✅ `https://play.google.com/store/apps/details?id=com.example.app&hl=en_US`

No need to clean up URLs - just copy and paste!

## 🎪 Example Output

```
========================================
SDK Detection
========================================

Searching for: pspdfkit
🔍 FOUND: Framework directory detected
  📦 PSPDFKit.framework
     Bundle ID: com.pspdfkit.sdk
     Version:   10.9.2
     Build:     2024.04.12.1601
     Size:       35M
🔍 FOUND: Binary dependency detected
  🔗 @rpath/PSPDFKit.framework/PSPDFKit

✅ RESULT: pspdfkit SDK IS PRESENT
```

## 📊 Features

### Automatic Report Naming
Reports are automatically named with:
- App bundle identifier (sanitized)
- Timestamp
- Unique per analysis

Example: `sdk-detection-com-customer-app-20251015-153416.txt`

### Multiple SDK Detection
Check for multiple SDK names at once:
```bash
./detect-sdk.sh -s pspdfkit -s nutrient -s firebase -b com.customer.app
```

### Detection Methods
1. **Framework Directory Inspection** - Most reliable
2. **Binary Dependency Analysis** - Uses `otool` to check linkage
3. **File Search** - Finds SDK-related files
4. **Version Detection** - Extracts SDK version and build info
5. **Size Calculation** - Shows how much of the app is your SDK

### Workflow Options

```bash
# Keep analysis files for manual inspection
./detect-sdk.sh -s pspdfkit -b com.customer.app --no-cleanup

# Verbose output for debugging
./detect-sdk.sh -s pspdfkit -b com.customer.app -v

# Custom report name
./detect-sdk.sh -s pspdfkit -b com.customer.app -o my-report.txt
```

## 📚 Documentation

### 👉 New to This? Start Here!
See **[GETTING_STARTED.md](GETTING_STARTED.md)** for:
- Simple, non-technical instructions (iOS focus)
- What the tool does in plain English
- Step-by-step walkthrough
- Common issues and solutions
- Understanding the results

### iOS-Specific Documentation
- **[SDK_DETECTION_GUIDE.md](SDK_DETECTION_GUIDE.md)** - Comprehensive iOS guide
  - Installation and authentication
  - Manual analysis steps
  - Understanding iOS app structure
  - Troubleshooting iOS issues

- **[USAGE_EXAMPLES.md](USAGE_EXAMPLES.md)** - Real-world iOS examples
  - Common use cases
  - Batch processing
  - CI/CD integration

### Android-Specific Documentation
- **[ANDROID_GUIDE.md](ANDROID_GUIDE.md)** - **🆕 Comprehensive Android guide**
  - APK acquisition methods
  - Analysis techniques
  - Understanding Android structure
  - Handling obfuscation
  - Troubleshooting Android issues

## 🔧 Command Reference

```bash
./detect-sdk.sh [OPTIONS]

OPTIONS:
  -s, --sdk <name>          SDK name to search for (repeatable)
  -u, --url <url>           App Store URL
  -b, --bundle <id>         Bundle identifier
  -i, --app-id <id>         App Store ID (numeric)
  -q, --search <term>       Search for app by name
  -o, --output <file>       Custom output filename
  -w, --work-dir <dir>      Custom working directory
  --no-cleanup              Keep temporary files
  -v, --verbose             Enable verbose output
  -h, --help                Show help message
```

## 🎯 Common Use Cases

### 1. Verify SDK Removal by Former Customer
```bash
./detect-sdk.sh -s pspdfkit -s nutrient -b com.formerclient.app
```

### 2. Check Multiple Customer Apps
```bash
# Check each customer
./detect-sdk.sh -s pspdfkit -b com.customer1.app
./detect-sdk.sh -s pspdfkit -b com.customer2.app
./detect-sdk.sh -s pspdfkit -b com.customer3.app

# All reports saved with unique names automatically
ls sdk-detection-*.txt
```

### 3. Rebranded SDK Detection
After rebranding from PSPDFKit to Nutrient:
```bash
./detect-sdk.sh -s pspdfkit -s nutrient -b com.customer.app
```

## 📋 Report Contents

Each report includes:
- App name, bundle ID, version, and size
- SDK detection results (found/not found)
- Framework versions and sizes
- Binary dependencies
- Detection methods used
- Compliance recommendations

## ⚠️ Legal Notice

**This tool is for legitimate defensive security purposes only:**

✅ Allowed:
- License compliance verification
- Security audits of apps you own or have permission to analyze
- Detecting unauthorized SDK usage by former customers
- Vulnerability assessments

❌ Not Allowed:
- Reverse engineering for malicious purposes
- Bypassing app protections or DRM
- Unauthorized analysis of third-party apps
- Creating competing products

## 🔐 Security & Privacy

- IPA files may contain sensitive information
- Do not share extracted app contents publicly
- Delete analysis files when done (or use `--no-cleanup` sparingly)
- Follow your company's legal procedures for compliance issues
- Consult with legal counsel for proper disclosure

## 🐛 Troubleshooting

### ipatool authentication issues
ipatool authentication is broken as of January 2026 due to Apple API changes. Use Apple Configurator 2 instead:
```bash
brew install fswatch
./watch-and-extract-ipa.sh
```
See [QUICK-START-APPLE-CONFIGURATOR.md](QUICK-START-APPLE-CONFIGURATOR.md) for full instructions. Track the ipatool fix at [github.com/majd/ipatool/issues/437](https://github.com/majd/ipatool/issues/437).

### App not found
```bash
# Search first to get correct bundle ID
./detect-sdk.sh -s pspdfkit -q "App Name"
```

### Permission errors
```bash
# Ensure script is executable
chmod +x detect-sdk.sh
```

### Need to re-analyze
Just run again - timestamps prevent overwriting previous reports.

## 📈 Real-World Example

Tyler Technologies' "Data Collect Mobile" app (former customer):

```bash
./detect-sdk.sh -s pspdfkit -s nutrient \
  -u https://apps.apple.com/us/app/data-collect-mobile/id1494756647
```

**Result**:
- ✅ PSPDFKit framework detected (v10.9.2, 35 MB)
- ❌ No Nutrient branding found
- **Conclusion**: App still contains old PSPDFKit SDK

Report saved to: `sdk-detection-com-scenedoc-mobile-ios-20251015-153416.txt`

## 🚀 Advanced Usage

### Batch Analysis Script
```bash
#!/bin/bash
for bundle_id in com.customer1.app com.customer2.app; do
    ./detect-sdk.sh -s pspdfkit -b "$bundle_id"
done
```

### Automated Compliance Reports
```bash
# Weekly compliance check
0 0 * * 0 cd /path/to/tool && ./detect-sdk.sh -s pspdfkit -b com.customer.app
```

## 📞 Support

1. Check the comprehensive guide: `SDK_DETECTION_GUIDE.md`
2. Review examples: `USAGE_EXAMPLES.md`
3. Run with verbose flag: `-v`
4. Keep analysis files for inspection: `--no-cleanup`

## 🔄 Updates

**Version**: 1.0
**Last Updated**: 2026-02-18

### Recent Changes
- ✅ **Apple Configurator 2 workflow** for iOS (ipatool workaround)
- ✅ **`watch-and-extract-ipa.sh`** — real-time IPA watcher (requires fswatch)
- ✅ **`--local-ipa` flag** for `detect-sdk-ios.sh` — analyze pre-extracted IPAs
- ✅ **XAPK automatic extraction and merging** (Android)
- ✅ Automatic report naming with bundle ID and timestamp
- ✅ Multiple SDK detection support
- ✅ Competitor product detection from configurable list
- ✅ List all frameworks/libraries mode (no SDK name required)
- ✅ Color-coded output for better readability
- ✅ Comprehensive error handling
- ✅ Report persistence after cleanup
- ✅ Spreadsheet-friendly report format (no formula conflicts)

## 📄 Files

```
.
├── detect-sdk.sh                    # Main automation script
├── SDK_DETECTION_GUIDE.md          # Comprehensive guide
├── USAGE_EXAMPLES.md               # Usage examples
├── README.md                       # This file
└── sdk-detection-*.txt             # Generated reports (unique per app)
```

## 🎓 Learn More

- **ipatool**: https://github.com/majd/ipatool
- **iOS App Structure**: See SDK_DETECTION_GUIDE.md
- **Batch Processing**: See USAGE_EXAMPLES.md

---

**Built for license compliance verification and security audits**
**Detect SDK presence • Generate reports • Ensure compliance**
