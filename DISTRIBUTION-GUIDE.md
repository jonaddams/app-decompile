# Distribution Guide - SDK Analyzer

## Files to Distribute

To share this tool with non-technical staff, provide these files:

### ✅ Required Files
```
app-decompile/
├── SDK Analyzer.app          ⭐ Main application (double-click to run)
├── detect-sdk-ios.sh         📱 iOS analysis backend
├── detect-sdk-android.sh     🤖 Android analysis backend
├── competitors.txt           📋 Competitor products list
├── library-info.txt          📚 Library descriptions database
├── QUICK-START.md            📖 Simple guide for non-technical users
└── GUI-App-README.md         📘 Detailed documentation
```

### Optional Files
- `SDK-Analyzer.applescript` - Source code (for developers)
- `DISTRIBUTION-GUIDE.md` - This file (for administrators)

## Distribution Methods

### Method 1: ZIP File (Recommended)
```bash
# Create a distributable ZIP
cd /Users/jonaddamsnutrient/SE/app-decompile
zip -r "SDK-Analyzer-v1.0.zip" \
  "SDK Analyzer.app" \
  detect-sdk-ios.sh \
  detect-sdk-android.sh \
  competitors.txt \
  library-info.txt \
  QUICK-START.md \
  GUI-App-README.md

# Result: SDK-Analyzer-v1.0.zip (ready to distribute)
```

Share this ZIP file via:
- Email (if under 25MB)
- Shared drive (Google Drive, Dropbox, etc.)
- Internal file sharing system

### Method 2: DMG Disk Image (More Professional)
```bash
# Create a DMG disk image
hdiutil create -volname "SDK Analyzer" -srcfolder "SDK Analyzer.app" -ov -format UDZO "SDK-Analyzer-v1.0.dmg"
```

## Pre-Distribution Checklist

Before distributing, verify:

- [ ] All scripts have execute permissions:
  ```bash
  chmod +x detect-sdk-ios.sh detect-sdk-android.sh
  ```

- [ ] Test the app on a clean Mac (without your development setup)

- [ ] Verify iOS authentication works:
  ```bash
  ipatool auth info
  ```

- [ ] Test with a known iOS app:
  ```bash
  open "SDK Analyzer.app"
  # Select iOS, paste URL, verify it completes
  ```

- [ ] Test with an Android APK (if applicable):
  ```bash
  open "SDK Analyzer.app"
  # Select Android, choose APK, verify it completes
  ```

## Installation Instructions for Recipients

### For Non-Technical Users
Send them `QUICK-START.md` with these simple steps:

1. **Unzip** the downloaded file
2. **Move** the folder to your Desktop or Documents
3. **Double-click** `SDK Analyzer.app`
4. **First time only**: Right-click → Open (to bypass macOS security)

### For IT/Technical Staff
Send them `GUI-App-README.md` with full documentation

## First-Time Setup (iOS)

Recipients will need to authenticate with ipatool for iOS analysis:

```bash
# One-time setup command
ipatool auth login --email their-apple-id@example.com
```

**Important notes for users:**
- Must use a real Apple ID (iTunes account)
- Can only download apps they've previously downloaded
- Must be in the same region as the app

## Troubleshooting Common Issues

### "App is damaged and can't be opened"
**Cause**: macOS Gatekeeper blocking unsigned app
**Fix**:
```bash
xattr -cr "SDK Analyzer.app"
```
Or right-click → Open → Click "Open"

### "Permission Denied" running scripts
**Cause**: Scripts lost execute permission during transfer
**Fix**:
```bash
cd /path/to/app-decompile
chmod +x detect-sdk-ios.sh detect-sdk-android.sh
```

### Scripts not found
**Cause**: App moved without the supporting scripts
**Fix**: Keep all files together in the same folder

## Customization Options

### Update Competitor List
Edit `competitors.txt` to add/remove competitor products:
```
# Add one company per line
NewCompany Inc.
AnotherCompetitor [with optional notes]
```

### Update Library Descriptions
Edit `library-info.txt` to add library information:
```
LibraryName|Description of what it does|Vendor Name
ExampleSDK.framework|Example SDK for demonstration|Example Corp
```

## Security Considerations

### What This Tool Does
- ✅ Downloads and analyzes apps locally
- ✅ Generates text reports
- ✅ All processing happens on the user's Mac
- ✅ No data sent to external servers

### What This Tool Does NOT Do
- ❌ Does not modify apps
- ❌ Does not crack or pirate apps
- ❌ Does not bypass DRM
- ❌ Does not send data externally

### Legal Compliance
Users should only analyze:
- Apps they have rights to analyze
- Apps for legitimate business purposes
- Apps for security/compliance review

## Version Control

Current Version: **1.0**
Release Date: October 2025

### Version History
- v1.0 (2025-10) - Initial release
  - macOS GUI application
  - iOS and Android support
  - Competitor detection
  - Library database

### Future Enhancements (Optional)
- [ ] Custom app icon
- [ ] Progress bar during analysis
- [ ] Export reports to PDF/HTML
- [ ] Batch analysis of multiple apps
- [ ] Windows/Linux versions

## Support & Maintenance

### Updating the Tool
To update with new competitors or library info:
1. Edit `competitors.txt` or `library-info.txt`
2. No need to rebuild the app
3. Redistribute the updated text files

### Adding New Features
To modify the app itself:
1. Edit `SDK-Analyzer.applescript`
2. Recompile: `osacompile -o "SDK Analyzer.app" SDK-Analyzer.applescript`
3. Test thoroughly
4. Redistribute

## Technical Requirements

### System Requirements
- macOS 10.15 (Catalina) or later
- 1GB free disk space (for temporary app downloads)
- Internet connection (for iOS downloads)

### Dependencies (Pre-installed on macOS)
- Bash 3.2+
- AppleScript
- Standard Unix tools (grep, sed, awk, etc.)

### Optional Dependencies
- `ipatool` - Auto-installed via Homebrew (iOS only)
- `apktool` - Required for advanced Android analysis
- Java - Required for apktool (Android only)

## Distribution Compliance

This tool is provided for:
- License compliance verification
- Security auditing
- Competitor analysis for business intelligence

Ensure all users understand:
- Only analyze apps you have rights to analyze
- Respect copyright and license agreements
- Use for legitimate business purposes only

## Questions & Support

For questions about:
- **Using the app**: See `QUICK-START.md`
- **Technical details**: See `GUI-App-README.md`
- **Script usage**: Run `./detect-sdk-ios.sh -h`

---

**Ready to Distribute!** 🚀

Create your ZIP file and share with your team!
