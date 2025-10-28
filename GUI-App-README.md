# SDK Analyzer - Desktop Application

A user-friendly graphical application for analyzing mobile apps to detect SDKs and frameworks.

## Features

- **Simple Point-and-Click Interface** - No command line knowledge required
- **Supports iOS and Android** - Analyze apps from both platforms
- **Automatic Report Generation** - Get detailed analysis reports
- **Native macOS Application** - Familiar Mac interface

## Installation

1. **No installation needed!** - Simply double-click `SDK Analyzer.app` to run

2. **First-time setup** (iOS only):
   - The first time you analyze an iOS app, you'll need to authenticate with ipatool
   - Open Terminal and run:
     ```bash
     ipatool auth login --email your@email.com
     ```
   - Enter your Apple ID password when prompted
   - This only needs to be done once

## How to Use

### Option 1: Double-Click to Run
1. Double-click `SDK Analyzer.app`
2. Choose your platform (iOS or Android)
3. Follow the prompts:
   - **iOS**: Enter the App Store URL
   - **Android**: Select your APK file
4. Wait for analysis to complete
5. View your report!

### Option 2: Drag and Drop (Alternative)
- You can still use the command-line scripts directly if preferred:
  - `./detect-sdk-ios.sh -u "URL"`
  - `./detect-sdk-android.sh -f "file.apk"`

## iOS Analysis

**What you need:**
- App Store URL (e.g., `https://apps.apple.com/us/app/example/id1234567890`)
- The app must be previously downloaded with your Apple ID
- The app must be available in your region

**How to get an App Store URL:**
1. Open the App Store on your Mac or iPhone
2. Find the app you want to analyze
3. Click "Share" → "Copy Link"
4. Paste this URL into the SDK Analyzer

**Common Issues:**
- **"password token is expired"** - Run: `ipatool auth login --email your@email.com`
- **"temporarily unavailable"** - The app must be previously downloaded with your Apple ID or available in your region

## Android Analysis

**What you need:**
- An APK file of the app you want to analyze

**How to get an APK:**
- Download from app stores
- Export from your Android device using ADB
- Use third-party APK download sites (for apps you have rights to analyze)

## Output Reports

Reports are saved in the same directory as the application:
- **iOS**: `framework-analysis-[bundle-id]-[timestamp].txt`
- **Android**: `library-analysis-[package-name]-[timestamp].txt`

Reports include:
- App information (name, version, bundle/package ID)
- List of all embedded frameworks/libraries
- Library descriptions and vendors
- Competitor product detection
- Dynamic library dependencies

## Competitor Detection

The analyzer automatically checks for competitor products listed in `competitors.txt`:
- 150+ PDF, document, and workflow competitors
- Flags any matches found in the app
- Highlights potential licensing concerns

## Advanced Options

For advanced users who want more control, use the command-line scripts directly:

**iOS:**
```bash
./detect-sdk-ios.sh -u "APP_STORE_URL"
./detect-sdk-ios.sh -b "com.bundle.id"
./detect-sdk-ios.sh -s pspdfkit -s nutrient -u "URL"  # Search for specific SDKs
./detect-sdk-ios.sh -u "URL" -v --no-cleanup  # Verbose with temp files kept
```

**Android:**
```bash
./detect-sdk-android.sh -f "app.apk"
./detect-sdk-android.sh -f "app.apk" -v  # Verbose output
./detect-sdk-android.sh -f "app.apk" --no-cleanup  # Keep temp files
```

## System Requirements

- **macOS** 10.15 (Catalina) or later
- **Internet connection** (for downloading iOS apps)
- **Apple ID** (for iOS app analysis)

## Troubleshooting

### iOS Issues

**Authentication Failed:**
```bash
# Re-authenticate with ipatool
ipatool auth login --email your@email.com
```

**App Download Failed:**
- Make sure you've previously downloaded the app with your Apple ID
- Check that the app is available in your region
- Try with a free app you know you've downloaded before

**Permission Denied:**
```bash
# Make scripts executable
chmod +x detect-sdk-ios.sh detect-sdk-android.sh
```

### Android Issues

**APK Extraction Failed:**
- Make sure you have read permissions for the APK file
- Check that the APK file is not corrupted
- Try copying the APK to your Desktop first

### General Issues

**App Won't Open:**
- Right-click → Open (first time only)
- macOS may block unsigned apps - go to System Preferences → Security & Privacy → Allow

**Scripts Not Found:**
- Make sure `SDK Analyzer.app` is in the same directory as the shell scripts
- Don't move the app without moving the scripts

## Files Structure

```
app-decompile/
├── SDK Analyzer.app          # Double-click to run (GUI)
├── SDK-Analyzer.applescript  # Source code for the app
├── detect-sdk-ios.sh         # iOS analysis script
├── detect-sdk-android.sh     # Android analysis script
├── competitors.txt           # List of competitor products
├── library-info.txt          # Library descriptions database
└── [generated reports]       # Analysis output files
```

## Technical Details

- **Built with**: AppleScript (native macOS)
- **iOS backend**: ipatool, otool, plutil
- **Android backend**: apktool, unzip, strings
- **Compatibility**: Bash 3.2+ (macOS default)

## Privacy & Security

- All analysis is done **locally** on your computer
- No data is sent to external servers
- Downloaded apps are stored temporarily and deleted after analysis
- Use `--no-cleanup` flag to keep temporary files for inspection

## Support

For issues or questions:
1. Check this README for troubleshooting tips
2. Review the command-line help: `./detect-sdk-ios.sh -h`
3. Check the script source code for detailed comments

## License Compliance

This tool is designed for:
- ✅ License compliance verification
- ✅ Security auditing of authorized apps
- ✅ Competitor analysis for legitimate business purposes

Please ensure you have the right to analyze any apps you process.
