# ⚠️ IMPORTANT: File Structure Requirements

## SDK Analyzer Requires All Files Together

**SDK Analyzer.app MUST be in the same folder as the supporting scripts!**

---

## Required File Structure

After extracting `SDK-Analyzer-v1.0.zip`, your folder should look like this:

```
SDK-Analyzer/
├── SDK Analyzer.app           ← The application
├── detect-sdk-ios.sh          ← iOS analysis script (required)
├── detect-sdk-android.sh      ← Android analysis script (required)
├── competitors.txt            ← Competitor product list (required)
├── library-info.txt           ← Library descriptions (required)
├── Fix-Security-Warning.command
├── SETUP-HELPER.sh
└── [documentation files...]
```

---

## ❌ Common Mistake

**DO NOT** do this:
- Extract the ZIP
- Move only `SDK Analyzer.app` to Applications folder
- Delete or move the other files

**This will cause the error:**
```
Analysis Failed
sh: ./detect-sdk-ios.sh: No such file or directory
```

---

## ✅ Correct Setup

### Option 1: Run from the Extracted Folder (Recommended)

1. Extract `SDK-Analyzer-v1.0.zip` to your desired location:
   - Desktop
   - Documents
   - Downloads
   - Any folder you prefer

2. **Keep ALL files together** in that folder

3. Double-click `SDK Analyzer.app` from that folder

4. The app will work correctly!

### Option 2: Move Everything Together

If you want to move the app:

1. Extract the ZIP

2. Move the **ENTIRE FOLDER** (with all files) to your desired location

3. **DO NOT** separate `SDK Analyzer.app` from the scripts

---

## Why This Is Required

SDK Analyzer is not a standalone application. It's a GUI wrapper that:

1. Collects input from you (URLs, file selections, credentials)
2. Calls the backend shell scripts (`detect-sdk-ios.sh` or `detect-sdk-android.sh`)
3. The scripts do the actual analysis
4. The app displays the results

**Without the scripts, the app cannot function.**

---

## Error Messages You'll See

### If Scripts Are Missing

```
❌ Setup Error

The analysis script is missing.

SDK Analyzer.app must be in the same folder as:
• detect-sdk-ios.sh
• detect-sdk-android.sh
• competitors.txt
• library-info.txt

Please:
1. Extract the complete SDK-Analyzer-v1.0.zip
2. Keep all files together in the same folder
3. Run SDK Analyzer.app from that folder

Current location: /Users/you/Desktop
```

This error appears when:
- You moved only the `.app` file
- You deleted the supporting scripts
- The scripts are in a different folder

---

## How to Fix

### If You Already Moved the App

1. **Re-extract** `SDK-Analyzer-v1.0.zip` to a new folder

2. **Keep all files together**

3. Run `SDK Analyzer.app` from that folder

### If You Want to Keep it Organized

Create a dedicated folder:

```bash
# Create a folder
mkdir -p ~/Applications/SDK-Analyzer

# Extract the ZIP into that folder
unzip SDK-Analyzer-v1.0.zip -d ~/Applications/SDK-Analyzer

# Run from there
open ~/Applications/SDK-Analyzer/SDK\ Analyzer.app
```

Or use Finder:
1. Create a new folder: `SDK-Analyzer`
2. Extract the ZIP into that folder
3. Double-click `SDK Analyzer.app` inside

---

## Checking Your Setup

To verify your setup is correct:

1. **Open Terminal**

2. **Navigate to the folder** containing SDK Analyzer.app:
   ```bash
   cd ~/Desktop/SDK-Analyzer  # Adjust path as needed
   ```

3. **List files**:
   ```bash
   ls -la
   ```

4. **You should see**:
   ```
   SDK Analyzer.app
   detect-sdk-ios.sh
   detect-sdk-android.sh
   competitors.txt
   library-info.txt
   ```

5. **If any are missing**, re-extract the ZIP

---

## Alternative: Create an Alias/Shortcut

If you want to launch the app from a different location without moving files:

### On macOS:

1. **Keep all files together** in their original location (e.g., `~/Documents/SDK-Analyzer/`)

2. **Create an alias** of `SDK Analyzer.app`:
   - Right-click `SDK Analyzer.app`
   - Click "Make Alias"
   - Move the alias to your desired location (Desktop, Dock, etc.)

3. **Launch via the alias** - it will run from the original location with all supporting files

---

## For IT Administrators

If deploying to multiple users:

### Option 1: Shared Network Location
- Extract to shared network drive
- All files stay together
- Users access from network location

### Option 2: Install Script
```bash
#!/bin/bash
# Extract to standardized location
INSTALL_DIR="/Applications/SDK-Analyzer"
sudo mkdir -p "$INSTALL_DIR"
sudo unzip SDK-Analyzer-v1.0.zip -d "$INSTALL_DIR"
sudo chmod +x "$INSTALL_DIR/detect-sdk-ios.sh"
sudo chmod +x "$INSTALL_DIR/detect-sdk-android.sh"

echo "Installed to $INSTALL_DIR"
echo "Users can run: open \"$INSTALL_DIR/SDK Analyzer.app\""
```

### Option 3: DMG Distribution (Future)
Consider creating a DMG that:
- Contains all required files
- Instructs users to copy the entire folder
- Prevents separation of files

---

## Summary

✅ **DO:**
- Extract the complete ZIP
- Keep all files together in one folder
- Run SDK Analyzer.app from that folder

❌ **DON'T:**
- Move only SDK Analyzer.app
- Delete supporting scripts
- Separate files into different folders

---

## Quick Checklist

Before running SDK Analyzer, verify:

- [ ] Extracted `SDK-Analyzer-v1.0.zip` completely
- [ ] `SDK Analyzer.app` is in the same folder as:
  - [ ] `detect-sdk-ios.sh`
  - [ ] `detect-sdk-android.sh`
  - [ ] `competitors.txt`
  - [ ] `library-info.txt`
- [ ] Double-clicking `SDK Analyzer.app` from that folder

If all checked, you're ready to use SDK Analyzer! ✅

---

## Still Having Issues?

If you followed these instructions and still see the error:

1. **Check file permissions:**
   ```bash
   ls -l detect-sdk-*.sh
   ```
   Should show: `-rwxr-xr-x` (executable)

2. **Make scripts executable if needed:**
   ```bash
   chmod +x detect-sdk-ios.sh detect-sdk-android.sh
   ```

3. **Verify you're in the right folder:**
   - Open the app
   - Note the "Current location" in the error message
   - Make sure the scripts are in that exact location

4. **See other documentation:**
   - [QUICK-START.md](QUICK-START.md)
   - [INSTALLATION-INSTRUCTIONS.md](INSTALLATION-INSTRUCTIONS.md)

---

**Remember: SDK Analyzer + Scripts = Working Tool**

Keep them together! 🤝
