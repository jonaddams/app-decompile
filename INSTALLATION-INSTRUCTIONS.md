# SDK Analyzer - Installation Instructions

## 📥 Step 1: Download & Extract

1. Download `SDK-Analyzer-v1.0.zip`
2. Double-click the ZIP to extract it
3. Move the folder to your Desktop or Documents

---

## 🔓 Step 2: Remove Security Block (First Time Only)

macOS will block the app because it's not signed. **This is safe - it's an internal tool.**

### Quick Fix (Recommended):

1. Open **Terminal** (find it in Applications → Utilities)
2. Copy and paste this command:
   ```bash
   xattr -cr ~/Downloads/"SDK Analyzer.app"
   ```
   **Note:** Change `~/Downloads/` if you put the app in a different folder
3. Press **Enter**
4. Close Terminal

### Alternative Method:

1. **Right-click** on "SDK Analyzer.app"
2. Choose **"Open"** from the menu
3. Click **"Open"** in the dialog that appears

---

## ✅ Step 3: Verify Setup (iOS Analysis Only)

Check if you have the required tools:

Open Terminal and run:
```bash
brew --version
ipatool --version
ipatool auth info
```

**If any command fails**, you need one-time setup:

```bash
# Install Homebrew (if needed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install ipatool (if needed)
brew install ipatool

# Authenticate with your Apple ID (if needed)
ipatool auth login --email your@email.com
```

**Android analysis** doesn't require these tools.

---

## 🚀 Step 4: Use the App

1. **Double-click** "SDK Analyzer.app"
2. Choose **iOS** or **Android**
3. Follow the prompts
4. Wait for analysis (1-5 minutes)
5. View your report!

---

## 📄 What's Included

- **SDK Analyzer.app** - The application (double-click to run)
- **QUICK-START.md** - Detailed guide for non-technical users
- **SECURITY-WORKAROUND.md** - Help with macOS security warnings
- **GUI-App-README.md** - Full documentation
- Backend scripts (work automatically)

---

## ❓ Troubleshooting

### Security Warning Won't Go Away

**Problem:** "SDK Analyzer cannot be opened" error persists

**Solution:**
1. Try the `xattr` command again with the full path
2. Or: System Settings → Privacy & Security → Click "Open Anyway"
3. See **SECURITY-WORKAROUND.md** for detailed help

### Homebrew Not Found (iOS Analysis)

**Problem:** "Homebrew not found" error

**Solution:** Install Homebrew and ipatool (see Step 3 above)

### Authentication Error (iOS Analysis)

**Problem:** "password token is expired"

**Solution:** Re-authenticate:
```bash
ipatool auth login --email your@email.com
```

### Can't Download iOS App

**Problem:** "temporarily unavailable"

**Reason:** You can only download apps that:
- You've previously downloaded with your Apple ID
- Are available in your region

**Solution:** Try with a free app you've already installed on your iPhone

---

## 💡 Tips

- **Keep everything together** - Don't move the app without the other files
- **Check notifications** - Progress updates appear in the corner
- **Be patient** - Large apps take 2-5 minutes to analyze
- **Clean up** - App offers to delete temp files after analysis

---

## 📞 Support

**For security warnings:** See SECURITY-WORKAROUND.md
**For usage help:** See QUICK-START.md
**For technical details:** See GUI-App-README.md
**For IT admins:** See DISTRIBUTION-GUIDE.md

---

## 🔒 Is This Safe?

**Yes!** This is an internal tool for analyzing mobile apps. It:
- ✅ Runs entirely on your Mac
- ✅ Doesn't send data anywhere
- ✅ Source code is available for inspection
- ✅ Only analyzes apps you provide

The security warning appears because the app isn't signed with a paid Apple Developer certificate ($99/year). For internal tools, this is normal.

---

## Quick Command Reference

```bash
# Remove security block
xattr -cr "SDK Analyzer.app"

# Check if tools are installed
brew --version
ipatool --version
ipatool auth info

# Install tools (if needed)
brew install ipatool
ipatool auth login --email your@email.com
```

---

**Ready to analyze!** 🎉

If you completed Steps 1-3, just double-click the app and start analyzing!
