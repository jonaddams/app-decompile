# iOS App SDK Detection Tool

A comprehensive toolkit for detecting SDK presence in iOS applications for license compliance verification and security audits.

## 🎯 Purpose

This tool helps you verify whether former customers have removed your SDK from their applications, ensuring license compliance. It's designed for legitimate defensive security purposes only.

## 📦 What's Included

1. **`detect-sdk.sh`** - Automated detection script
2. **`GETTING_STARTED.md`** - **👉 START HERE** - Simple guide for non-technical users
3. **`SDK_DETECTION_GUIDE.md`** - Comprehensive step-by-step guide
4. **`USAGE_EXAMPLES.md`** - Real-world usage examples and workflows

## ⚡ Quick Start

### 1. First Time? No Problem!

The script **automatically installs everything** you need. Just download and run!

**No manual setup required** - the script will:
- ✅ Install Homebrew (if needed)
- ✅ Install ipatool (if needed)
- ✅ Prompt for Apple ID authentication (if needed)

### 2. Run Analysis

```bash
# Make script executable (first time only)
chmod +x detect-sdk.sh

# Analyze an app by bundle ID
./detect-sdk.sh -s pspdfkit -s nutrient -b com.scenedoc.mobile.ios

# Or by App Store URL
./detect-sdk.sh -s pspdfkit -u https://apps.apple.com/us/app/data-collect-mobile/id1494756647
```

### 3. Check Results

The script automatically generates a report named with the app's bundle ID and timestamp:

```
sdk-detection-com-scenedoc-mobile-ios-20251015-153416.txt
```

## 💡 Smart URL Handling

The tool automatically handles App Store URLs with query parameters, so you can paste them directly:

✅ `https://apps.apple.com/us/app/app-name/id1234567890`
✅ `https://apps.apple.com/us/app/app-name/id1234567890?l=es-MX`
✅ `https://apps.apple.com/gb/app/app-name/id1234567890?mt=8&uo=4#screenshots`

No need to clean up the URL - just copy and paste!

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
- Simple, non-technical instructions
- What the tool does in plain English
- Step-by-step walkthrough with screenshots
- Common issues and solutions
- Understanding the results

### For Detailed Instructions
See **[SDK_DETECTION_GUIDE.md](SDK_DETECTION_GUIDE.md)** for:
- Complete installation instructions
- Tool setup and authentication
- Manual analysis steps
- Troubleshooting common issues
- Understanding iOS app structure

### For Usage Examples
See **[USAGE_EXAMPLES.md](USAGE_EXAMPLES.md)** for:
- Common use cases
- Batch processing multiple apps
- Organizing reports
- Integration with CI/CD
- Real-world workflows

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
```bash
ipatool auth revoke
ipatool auth login --email your@email.com
```

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
**Last Updated**: 2025-10-15

### Recent Changes
- ✅ Automatic report naming with bundle ID and timestamp
- ✅ Multiple SDK detection support
- ✅ Color-coded output for better readability
- ✅ Comprehensive error handling
- ✅ Report persistence after cleanup

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
