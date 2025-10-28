# SDK Analyzer - Desktop Application ✨

**A simple, user-friendly desktop app for analyzing mobile apps to detect SDKs and frameworks.**

Perfect for non-technical staff who need to analyze apps without using the command line!

---

## 🎯 What's New

**GUI Application Now Available!**

No more command line required - just double-click and go!

---

## 📦 What You Get

### The Main Application
**`SDK Analyzer.app`** - Double-click to run
- ✅ Friendly point-and-click interface
- ✅ Supports both iOS and Android
- ✅ Automatic report generation
- ✅ Built-in error messages and help
- ✅ Native macOS application

### Documentation
- **`QUICK-START.md`** - For non-technical users (START HERE!)
- **`GUI-App-README.md`** - Detailed guide with troubleshooting
- **`DISTRIBUTION-GUIDE.md`** - For IT administrators

---

## 🚀 Quick Start (For Users)

1. **Unzip** the downloaded file
2. **Double-click** `SDK Analyzer.app`
3. **Choose** iOS or Android
4. **Enter** App Store URL or select APK file
5. **Wait** for analysis to complete
6. **View** your report!

**That's it!** No terminal, no commands, no coding required.

---

## 📱 For iOS Analysis

**What you need:**
- App Store URL (e.g., `https://apps.apple.com/us/app/example/id1234567890`)

**First-time setup:**
Open Terminal and run once:
```bash
ipatool auth login --email your@email.com
```

**How to get App Store URLs:**
- Open App Store → Find app → Share → Copy Link

---

## 🤖 For Android Analysis

**What you need:**
- APK file of the app

**How to get APKs:**
- Download from app stores
- Export from Android device
- Use APK download sites

---

## 📊 What It Analyzes

The tool detects and reports:
- ✅ All embedded frameworks and libraries
- ✅ Library descriptions and vendors
- ✅ Competitor products (150+ companies tracked)
- ✅ Dynamic dependencies
- ✅ App version and bundle information

---

## 🎁 Distribution Package

**File:** `SDK-Analyzer-v1.0.zip` (826 KB)

**Contains:**
```
✓ SDK Analyzer.app          (Main application)
✓ detect-sdk-ios.sh         (iOS backend script)
✓ detect-sdk-android.sh     (Android backend script)
✓ competitors.txt           (Competitor database)
✓ library-info.txt          (Library descriptions)
✓ QUICK-START.md            (Simple guide)
✓ GUI-App-README.md         (Full documentation)
✓ DISTRIBUTION-GUIDE.md     (IT admin guide)
```

---

## 💡 Key Features

### For Non-Technical Users
- **No command line** - Point and click interface
- **Simple dialogs** - Clear instructions at each step
- **Error messages** - Helpful guidance when things go wrong
- **One-click reports** - Open results directly from success dialog
- **Notifications** - Progress updates in macOS notification center

### For Technical Users
- **Command line still available** - Scripts work as before
- **Verbose mode** - Debug output available via CLI
- **Customizable** - Edit competitor and library databases
- **No cleanup option** - Keep temp files for inspection
- **Extensible** - AppleScript source included

---

## 🔧 System Requirements

- macOS 10.15 (Catalina) or later
- Internet connection (for iOS downloads)
- Apple ID (for iOS apps)
- 1GB free disk space

---

## 🏆 Improvements Over Command Line

| Feature | Command Line | GUI App |
|---------|--------------|---------|
| **Ease of Use** | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Error Messages** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **User-Friendly** | ⭐ | ⭐⭐⭐⭐⭐ |
| **Progress Feedback** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Report Access** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Power User Options** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

**Winner:** GUI for simplicity, CLI for advanced features (both available!)

---

## 📖 Documentation Summary

### For End Users (Non-Technical)
👉 **Read: `QUICK-START.md`**
- Simple step-by-step instructions
- Screenshots of what to expect
- Common issues and fixes
- No technical jargon

### For Power Users
👉 **Read: `GUI-App-README.md`**
- Detailed feature documentation
- Advanced CLI options
- Technical architecture
- Troubleshooting guide

### For IT Administrators
👉 **Read: `DISTRIBUTION-GUIDE.md`**
- How to distribute the tool
- Installation instructions
- Security considerations
- Customization options

---

## 🎨 Usage Examples

### Example 1: Analyze iOS App
```
1. Double-click SDK Analyzer.app
2. Click "iOS (App Store)"
3. Paste: https://apps.apple.com/us/app/example/id123456
4. Click "Analyze"
5. Wait 1-2 minutes
6. Click "Open Report"
```

### Example 2: Analyze Android App
```
1. Double-click SDK Analyzer.app
2. Click "Android (APK)"
3. Browse to your APK file
4. Click "Open"
5. Wait 1-2 minutes
6. Click "Open Report"
```

---

## ⚡ Command Line Still Available

For advanced users, the shell scripts work exactly as before:

```bash
# iOS analysis
./detect-sdk-ios.sh -u "https://apps.apple.com/us/app/example/id123"

# Android analysis
./detect-sdk-android.sh -f app.apk

# Verbose mode
./detect-sdk-ios.sh -u "URL" -v

# Keep temp files
./detect-sdk-android.sh -f app.apk --no-cleanup

# Search for specific SDKs
./detect-sdk-ios.sh -s pspdfkit -s nutrient -u "URL"
```

---

## 🐛 Known Issues

### macOS Security Warning
**Issue:** "SDK Analyzer.app can't be opened"
**Fix:** Right-click → Open → Click "Open"

### First Launch Slow
**Issue:** App seems unresponsive on first run
**Why:** macOS is verifying the app signature
**Fix:** Wait 10-15 seconds, it will launch

### iOS Authentication
**Issue:** "Password token expired"
**Fix:** Run `ipatool auth login --email your@email.com` in Terminal

---

## 🔐 Privacy & Security

- ✅ **All processing is local** - No data sent to external servers
- ✅ **Open source scripts** - Review the code anytime
- ✅ **No telemetry** - We don't track usage
- ✅ **Secure downloads** - Uses official Apple/Google APIs
- ✅ **Temporary files deleted** - Cleanup after analysis

---

## 📞 Getting Help

1. **First**: Check `QUICK-START.md` for common issues
2. **Second**: Read `GUI-App-README.md` for detailed help
3. **Third**: Run `./detect-sdk-ios.sh -h` for CLI help
4. **Last**: Contact your IT administrator

---

## 🎉 Success Criteria

You'll know it's working when:
- ✅ Dialog boxes appear when you run the app
- ✅ Notifications show "Starting analysis..."
- ✅ Success dialog appears with "Open Report" button
- ✅ Report file opens in your default text editor
- ✅ Report contains app information and framework list

---

## 📦 Ready to Share

**Distribute:** `SDK-Analyzer-v1.0.zip`

**Recipients need:**
1. A Mac running macOS 10.15+
2. The ZIP file
3. `QUICK-START.md` guide
4. Apple ID (for iOS analysis only)

**That's all!** No installation, no dependencies, just unzip and run.

---

## 🚀 Version

**Version:** 1.0
**Release:** October 2025
**Platform:** macOS only (Windows/Linux versions not available)

---

## 📄 License & Compliance

This tool is designed for:
- ✅ License compliance verification
- ✅ Security auditing
- ✅ Competitor analysis
- ✅ Business intelligence

Please ensure you have rights to analyze any apps you process.

---

## 🎯 Next Steps

**For End Users:**
1. Read `QUICK-START.md`
2. Double-click `SDK Analyzer.app`
3. Start analyzing!

**For IT Admins:**
1. Read `DISTRIBUTION-GUIDE.md`
2. Test the app
3. Distribute to your team

**For Developers:**
1. Review `SDK-Analyzer.applescript`
2. Check shell scripts for customization
3. Modify competitor/library databases as needed

---

**Enjoy the new GUI!** 🎊

No more scary command line for your non-technical colleagues!
