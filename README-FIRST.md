# 📱 SDK Analyzer - READ THIS FIRST!

**A GUI tool for analyzing mobile apps to detect SDKs and frameworks**

---

## ⚠️ IMPORTANT: Setup Required!

**macOS will quarantine this app after download. You MUST run this command before using:**

```bash
xattr -cr ~/Downloads/SDK\ Analyzer.app
```

**Adjust the path** based on where you extracted the ZIP:
- Desktop: `xattr -cr ~/Desktop/SDK-Analyzer/SDK\ Analyzer.app`
- Documents: `xattr -cr ~/Documents/SDK-Analyzer/SDK\ Analyzer.app`

### Why?
macOS "translocates" downloaded apps to a temp directory, preventing SDK Analyzer from finding its required scripts. This command removes the quarantine flag.

### Alternative
After extracting, move the entire folder to a different location (e.g., Desktop), which sometimes clears the quarantine automatically.

---

## 🚀 Quick Start

### 1. Extract the ZIP
Extract `SDK-Analyzer-v1.0.zip` and **keep all files together** in the same folder.

### 2. Remove Quarantine (Critical!)
```bash
xattr -cr path/to/SDK\ Analyzer.app
```

### 3. First-Time Security Dialog
When you first open the app, macOS may block it:
1. System Settings → Privacy & Security
2. Click "Open Anyway"
3. Try opening the app again

See [SIMPLE-FIX-GUIDE.md](SIMPLE-FIX-GUIDE.md) for step-by-step instructions.

### 4. Run the App
Double-click **SDK Analyzer.app**

### 5. Choose Platform
- **iOS (App Store)** - Enter App Store URL
- **Android (APK)** - Select APK file

### 6. First-Time iOS Setup
If analyzing iOS apps for the first time:
- You'll be guided through installing `ipatool` (one-time)
- You'll authenticate with your Apple ID (one-time)
- 2FA is supported if you have it enabled

### 7. Wait for Analysis
Analysis takes 1-5 minutes depending on app size.

### 8. View Report
When complete, the report opens automatically showing detected SDKs.

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| **[QUICK-START.md](QUICK-START.md)** | Simple step-by-step guide |
| **[APP-TRANSLOCATION-FIX.md](APP-TRANSLOCATION-FIX.md)** | Fix for "scripts missing" error |
| **[SIMPLE-FIX-GUIDE.md](SIMPLE-FIX-GUIDE.md)** | Security warning fix (6 steps) |
| **[TESTED-FIX-INSTRUCTIONS.md](TESTED-FIX-INSTRUCTIONS.md)** | Detailed security fix guide |
| **[IMPORTANT-FILE-STRUCTURE.md](IMPORTANT-FILE-STRUCTURE.md)** | File organization requirements |
| **[GUI-PASSWORD-FIX-v1.0.7.md](GUI-PASSWORD-FIX-v1.0.7.md)** | Authentication improvements |

---

## 🔧 Requirements

- **macOS** (tested on Ventura and later)
- **Homebrew** (installed automatically for iOS analysis)
- **ipatool** (installed automatically for iOS analysis)
- **Apple ID** (for iOS App Store downloads)
- **Internet connection** (for downloads and authentication)

---

## ✅ What Works

✅ iOS app analysis via App Store URL
✅ Android app analysis via APK file
✅ GUI-based Apple ID authentication
✅ Two-factor authentication (2FA) support
✅ Automatic ipatool installation
✅ Competitor product detection
✅ Library identification
✅ Comprehensive reports

---

## ❌ Common Issues & Fixes

### "Analysis script is missing"

**Symptom:** Error shows `/AppTranslocation/` in path

**Cause:** macOS quarantine/translocation

**Fix:** Run `xattr -cr "SDK Analyzer.app"`

See: [APP-TRANSLOCATION-FIX.md](APP-TRANSLOCATION-FIX.md)

### "SDK Analyzer Not Opened"

**Symptom:** Security warning blocks app

**Cause:** Unsigned app (normal!)

**Fix:** System Settings → Privacy & Security → Open Anyway

See: [SIMPLE-FIX-GUIDE.md](SIMPLE-FIX-GUIDE.md)

### "ipatool: command not found"

**Symptom:** Error during iOS analysis

**Cause:** ipatool not installed

**Fix:** App now detects this and offers automatic installation

### "Authentication Failed"

**Symptom:** Can't authenticate with Apple ID

**Cause:** Fixed in v1.0.7 - update to latest version

**Fix:** Use GUI password prompts (no Terminal needed)

See: [GUI-PASSWORD-FIX-v1.0.7.md](GUI-PASSWORD-FIX-v1.0.7.md)

---

## 📂 File Structure

**Required files (must stay together):**
```
SDK-Analyzer/
├── SDK Analyzer.app           ← The GUI application
├── detect-sdk-ios.sh          ← iOS analysis backend
├── detect-sdk-android.sh      ← Android analysis backend
├── competitors.txt            ← Competitor database
├── library-info.txt           ← Library descriptions
└── [documentation files...]
```

**DO NOT** move only `SDK Analyzer.app` - keep all files together!

---

## 🎯 Workflow

### iOS App Analysis
1. Open app → Select "iOS (App Store)"
2. If first time: Install ipatool (guided)
3. If first time: Authenticate with Apple ID
4. Enter App Store URL
5. App downloads and analyzes
6. Report opens automatically

### Android App Analysis
1. Open app → Select "Android (APK)"
2. Browse to APK file
3. App extracts and analyzes
4. Report opens automatically

---

## 🔒 Security & Privacy

✅ **Your data:** Never leaves your Mac
✅ **Apple ID:** Used only for ipatool authentication
✅ **Password:** Hidden when entering, not stored
✅ **Auth token:** Stored securely in macOS keychain
✅ **Source code:** Available in `.applescript` file
✅ **Open source:** Shell scripts are readable

---

## 🐛 Troubleshooting

### General Tips
1. **Always** run `xattr -cr` after extracting
2. **Keep** all files together in one folder
3. **Check** documentation files for specific issues
4. **Look** for error messages mentioning:
   - `/AppTranslocation/` → See APP-TRANSLOCATION-FIX.md
   - "script is missing" → Check file structure
   - "cannot be opened" → See SIMPLE-FIX-GUIDE.md

### Still Having Issues?
1. Re-download the ZIP
2. Extract to a fresh location
3. Run `xattr -cr` on the entire folder:
   ```bash
   xattr -cr ~/Desktop/SDK-Analyzer/
   ```
4. Make sure all required files are present
5. Check Terminal output for specific errors

---

## 📊 What Gets Analyzed

The app detects:
- **iOS/Android SDKs** (Firebase, Amplitude, etc.)
- **UI frameworks** (React Native, Flutter, etc.)
- **Networking libraries** (Alamofire, Retrofit, etc.)
- **Analytics tools** (Google Analytics, Mixpanel, etc.)
- **Crash reporting** (Crashlytics, Sentry, etc.)
- **Competitor products** (custom list in `competitors.txt`)

Reports include:
- Library names and descriptions
- Competitor product matches
- Full list of detected frameworks
- Analysis metadata

---

## 🔄 Version History

**v1.0.7** (Current)
- ✅ GUI password authentication
- ✅ 2FA support
- ✅ Automatic ipatool detection
- ✅ App translocation detection
- ✅ Clear error messages

**Previous versions:**
- v1.0.6: ipatool installation guidance
- v1.0.5: Apple ID authentication integration
- v1.0.4: GUI application created

---

## 💡 Tips

- **Create an alias** to SDK Analyzer.app for easy access (keeps files together)
- **Keep the folder** in a permanent location, not Downloads
- **Update scripts** by editing `.sh` files (app uses them directly)
- **Add competitors** by editing `competitors.txt`
- **Add library info** by editing `library-info.txt`

---

## 📝 For Developers

### Files You Can Edit
- `detect-sdk-ios.sh` - iOS analysis logic
- `detect-sdk-android.sh` - Android analysis logic
- `competitors.txt` - Competitor product list
- `library-info.txt` - Library descriptions
- `SDK-Analyzer.applescript` - GUI logic (recompile after changes)

### Recompile the App
```bash
osacompile -o "SDK Analyzer.app" SDK-Analyzer.applescript
```

### Remove Quarantine from New Build
```bash
xattr -cr "SDK Analyzer.app"
```

---

## 🎉 Getting Started Checklist

Before using SDK Analyzer:

- [ ] Extracted `SDK-Analyzer-v1.0.zip` completely
- [ ] Ran `xattr -cr "SDK Analyzer.app"` command
- [ ] All files are together in the same folder
- [ ] Read [QUICK-START.md](QUICK-START.md) for overview
- [ ] Ready to open the app!

---

## 📞 Need Help?

1. **Check the docs** (see list above)
2. **Look for your error** in troubleshooting sections
3. **Verify setup** (quarantine removed, files together)
4. **Contact** the person who sent you this tool

---

**Ready?** Run `xattr -cr "SDK Analyzer.app"` and double-click the app!

Enjoy analyzing! 📱✨
