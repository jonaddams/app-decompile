# Quick Start: iOS SDK Detection with Apple Configurator

> **Note:** This guide provides a workaround for the broken ipatool authentication issue.

## 🎯 Quick Summary

**Problem:** ipatool authentication is broken (Apple changed their API in Jan 2026)
**Solution:** Use Apple Configurator 2 to extract IPAs, then analyze them
**Time:** ~5 minutes per app

---

## 📋 One-Time Setup (Do This Once)

### 1. Install Apple Configurator 2
```bash
# Option A: Open Mac App Store
open "macappstore://apps.apple.com/us/app/apple-configurator/id1037126344"

# Option B: Search "Apple Configurator 2" in Mac App Store
```

### 2. Make Helper Scripts Executable
```bash
cd /path/to/sdk-analyzer
chmod +x extract-ipa.sh
chmod +x detect-sdk-ios.sh
```

---

## 🚀 How to Analyze an App (3 Easy Steps)

### Step 1: Download App via Apple Configurator

1. **Install the target app on your iPhone** (from App Store)
2. **Connect iPhone to Mac** (USB cable)
3. **Open Apple Configurator 2**
4. **Click on your iPhone icon**
5. **Go to:** Actions → Add → Apps...
6. **Sign in** with your Apple ID (if prompted)
7. **Search** for the app by name
8. **Select** the app and click "Add"
9. **Wait** for download to complete (~30 seconds)

### Step 2: Extract the IPA

```bash
cd /path/to/sdk-analyzer
./extract-ipa.sh
```

This copies the IPA from Apple Configurator's cache to `~/Desktop/extracted-ipas/`

### Step 3: Analyze for Your SDKs

```bash
# List all frameworks in the app
./detect-sdk-ios.sh --local-ipa ~/Desktop/extracted-ipas/YourApp.ipa

# Or search for specific SDKs
./detect-sdk-ios.sh --sdk pspdfkit --sdk nutrient --local-ipa ~/Desktop/extracted-ipas/YourApp.ipa
```

Done! 🎉

---

## 📝 Real Example

Let's check if Instagram uses your SDK:

```bash
# 1. Download Instagram via Apple Configurator 2
#    (Install on iPhone, connect to Mac, use Apple Configurator)

# 2. Extract the IPA
./extract-ipa.sh

# 3. Analyze
./detect-sdk-ios.sh --sdk pspdfkit --sdk nutrient --local-ipa ~/Desktop/extracted-ipas/Instagram*.ipa
```

---

## 🔍 Understanding the Output

The script will show:

```
✅ FOUND: pspdfkit SDK IS PRESENT
  📦 PSPDFKit.framework
     Bundle ID: com.pspdfkit.PSPDFKit
     Version:   12.5.0
     Build:     1000
     Size:      45MB
```

Or:

```
❌ RESULT: pspdfkit SDK NOT DETECTED
```

A detailed report is saved to your project folder.

---

## 💡 Tips & Tricks

### Extract Multiple Apps Quickly
```bash
# Download 3 apps via Apple Configurator (without disconnecting iPhone)
# Then extract all at once:
./extract-ipa.sh
```

### Batch Analysis
```bash
# Analyze all extracted IPAs
for ipa in ~/Desktop/extracted-ipas/*.ipa; do
    echo "Analyzing: $(basename "$ipa")"
    ./detect-sdk-ios.sh --sdk pspdfkit --local-ipa "$ipa"
    echo "---"
done
```

### Keep IPA Files Organized
```bash
# Rename IPAs with app names for easy tracking
cd ~/Desktop/extracted-ipas/
mv "*.ipa" "Instagram-$(date +%Y%m%d).ipa"
```

### Quick Manual Check (No Script)
```bash
# Just want to peek inside?
cd ~/Desktop/extracted-ipas/
unzip -q YourApp.ipa -d temp/
ls temp/Payload/*.app/Frameworks/ | grep -i pspdfkit
```

---

## ⚠️ Common Issues

### "No IPAs found in cache"
**Fix:** Make sure you completed Step 1 (download via Apple Configurator) and run `extract-ipa.sh` immediately after downloading.

### "Trust This Computer" doesn't appear
**Fix:** Disconnect/reconnect iPhone, try different USB cable, or restart both devices.

### Can't find the extracted IPA
**Fix:** IPAs are saved to `~/Desktop/extracted-ipas/` by default. Check there first.

### App not available in Apple Configurator
**Fix:** The app might not be available in your region, or it's an enterprise app. Try a different app or different region App Store account.

---

## 📊 Comparison: Old vs New Method

| Feature | ipatool (Broken) | Apple Configurator |
|---------|------------------|-------------------|
| Works Now? | ❌ No | ✅ Yes |
| Authentication | ❌ Broken | ✅ Official Apple |
| Automation | ✅ CLI | ❌ Manual GUI |
| Physical Device | ❌ Not needed | ✅ Required |
| Cost | Free | Free |
| Reliability | ❌ Broken | ✅ Stable |

---

## 🎓 Advanced: Automating with GUI Scripting

For power users who want to automate Apple Configurator:

```applescript
-- AppleScript to automate Apple Configurator
-- (This is advanced - stick with manual for now)
tell application "Apple Configurator 2"
    activate
    -- Add automation here
end tell
```

---

## 📚 Related Files

- `APPLE-CONFIGURATOR-GUIDE.md` - Detailed step-by-step guide
- `extract-ipa.sh` - Helper script to copy IPAs from cache
- `detect-sdk-ios.sh` - Main analysis script (now supports --local-ipa)
- `IPATOOL-FIX-v1.0.6.md` - Historical note about ipatool issues

---

## ✅ Checklist for New Users

- [ ] Install Apple Configurator 2
- [ ] Connect iPhone to Mac (USB)
- [ ] Download target app via Apple Configurator
- [ ] Run `./extract-ipa.sh`
- [ ] Run `./detect-sdk-ios.sh --local-ipa ~/Desktop/extracted-ipas/YourApp.ipa`
- [ ] Review the generated report

---

**Status:** ✅ Working Solution
**Last Updated:** February 16, 2026
**Alternative to:** Broken ipatool authentication
