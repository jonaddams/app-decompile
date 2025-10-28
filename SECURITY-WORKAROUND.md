# Security Warning Workaround

## The Issue

When users try to open "SDK Analyzer.app" for the first time, macOS shows this error:

```
"SDK Analyzer" Not Opened

Apple could not verify "SDK Analyzer" is free of malware that
may harm your Mac or compromise your privacy.

[Move to Trash]  [Done]
```

## Why This Happens

macOS Gatekeeper blocks apps that aren't signed with an Apple Developer Certificate. Since this is an internal tool distributed within your organization, it doesn't have a paid Apple Developer signature ($99/year).

**This is a false positive** - the app is safe, but macOS can't verify it automatically.

## Solution: Remove Quarantine Attribute

The app has a "quarantine" flag that macOS adds to downloaded files. Removing this flag allows the app to run.

### Method 1: Terminal Command (Recommended)

**For the user experiencing the issue:**

1. Open **Terminal** (Applications → Utilities → Terminal)

2. Copy and paste this command:
   ```bash
   xattr -cr ~/Downloads/"SDK Analyzer.app"
   ```
   (Adjust the path if the app is in a different location)

3. Press **Enter**

4. Try opening the app again by **double-clicking** it

**The app should now open without warnings!**

### Method 2: Right-Click Method

Sometimes this works, but may not bypass the strictest Gatekeeper settings:

1. **Right-click** (or Control-click) on "SDK Analyzer.app"
2. Select **"Open"** from the menu
3. A dialog appears with an "Open" button
4. Click **"Open"**

If this doesn't work, use Method 1 above.

### Method 3: System Settings (One-Time Override)

If the error already appeared:

1. Open **System Settings** (or System Preferences)
2. Go to **Privacy & Security**
3. Scroll down to the "Security" section
4. You should see: "SDK Analyzer was blocked from use because it is not from an identified developer"
5. Click **"Open Anyway"**
6. Confirm by clicking **"Open"** in the popup

## For IT Administrators: Bulk Deployment

### Option A: Pre-Process the App

Before distributing, remove the quarantine attribute:

```bash
# Remove quarantine from the app
xattr -cr "SDK Analyzer.app"

# Verify it's removed
xattr -l "SDK Analyzer.app"  # Should show nothing

# Create a ZIP without quarantine attributes
zip -r SDK-Analyzer-v1.0-clean.zip "SDK Analyzer.app" <other files>
```

**Problem:** Users who download the ZIP will have the quarantine re-applied by their browser.

### Option B: Provide a Setup Script

Create a setup script users run once:

**setup.sh:**
```bash
#!/bin/bash
echo "Setting up SDK Analyzer..."
xattr -cr "SDK Analyzer.app"
echo "✅ Setup complete! You can now use SDK Analyzer.app"
```

Distribute this with the app and have users run:
```bash
bash setup.sh
```

### Option C: MDM/Profile Installation

For managed Macs using MDM (Mobile Device Management):

Create a profile that allows the app, or pre-install with quarantine removed.

### Option D: Code Signing (Requires Apple Developer Account)

**Long-term solution:**

1. Purchase Apple Developer Account ($99/year)
2. Create a Developer ID certificate
3. Sign the app:
   ```bash
   codesign --force --deep --sign "Developer ID Application: Your Name" "SDK Analyzer.app"
   ```
4. Notarize with Apple:
   ```bash
   xcrun notarytool submit "SDK Analyzer.zip" --wait
   xcrun stapler staple "SDK Analyzer.app"
   ```

This makes the warning go away completely for all users.

## Quick Reference Card

**For End Users - Quick Fix:**

Open Terminal and run:
```bash
xattr -cr ~/Downloads/"SDK Analyzer.app"
```

Then double-click the app normally.

---

## Understanding the Quarantine Attribute

### What is it?

macOS adds a special "quarantine" attribute (`com.apple.quarantine`) to files downloaded from:
- Web browsers (Safari, Chrome, Firefox)
- Email attachments
- AirDrop transfers
- ZIP files downloaded from cloud storage

### Why does it exist?

To protect users from accidentally running malware downloaded from the internet.

### Is the app actually malware?

**No!** This is a legitimate internal tool. The warning appears because:
- The app isn't signed with a paid Apple Developer certificate
- macOS doesn't recognize the developer
- macOS errs on the side of caution

### How to verify the app is safe?

You can inspect the AppleScript source code:
```bash
# View the app's main script
cat "SDK Analyzer.app/Contents/Resources/Scripts/main.scpt"
```

The source is also available in `SDK-Analyzer.applescript`.

## Troubleshooting

### "Operation not permitted"

If the `xattr` command fails with "operation not permitted":

1. Make sure you're the owner: `ls -la "SDK Analyzer.app"`
2. Try with the full path: `xattr -cr "/full/path/to/SDK Analyzer.app"`
3. Check Terminal has Full Disk Access:
   - System Settings → Privacy & Security → Full Disk Access
   - Enable Terminal if needed

### "No such file or directory"

The path is wrong. Common locations:
- `~/Downloads/"SDK Analyzer.app"`
- `~/Desktop/"SDK Analyzer.app"`
- `~/Documents/app-decompile/"SDK Analyzer.app"`

Use tab completion or drag the app into Terminal to get the path.

### Still doesn't work

Try all three methods in order:
1. `xattr -cr` command
2. Right-click → Open
3. System Settings → Open Anyway

If none work, contact IT support.

## Prevention

### For Future Releases

To minimize this issue:

1. **Distribute via internal network** - Apps on corporate file servers may not get quarantined
2. **Use code signing** - Invest in Apple Developer account
3. **Include instructions** - Always include this workaround guide
4. **Setup script** - Include an automated setup.sh script
5. **Video tutorial** - Create a quick screen recording showing the fix

## FAQ

**Q: Is this safe?**
A: Yes, the app is safe. It's an AppleScript wrapper around shell scripts that analyze mobile apps. All source code is available for inspection.

**Q: Will this disable security for other apps?**
A: No, this only affects "SDK Analyzer.app". Other security features remain active.

**Q: Do I need to do this every time?**
A: No, only once. After removing the quarantine attribute, the app opens normally forever.

**Q: Can I just disable Gatekeeper entirely?**
A: Not recommended. Use the `xattr` command instead to only allow this specific app.

**Q: Why not just sign the app?**
A: Code signing requires a paid Apple Developer account ($99/year) and additional complexity. For internal tools, the workaround is sufficient.

**Q: My company blocks Terminal access**
A: Contact your IT administrator. They can either:
   - Remove the quarantine attribute before distributing
   - Add an exception for this app
   - Sign the app with a corporate certificate

## Support

If you continue to have issues:

1. Screenshot the exact error message
2. Note your macOS version: Apple menu →  About This Mac
3. Note where the app is located
4. Contact the person who distributed the app

---

## Summary

**The Problem:** macOS blocks unsigned apps from unknown developers

**The Solution:** Remove quarantine attribute with:
```bash
xattr -cr "SDK Analyzer.app"
```

**One-Time Fix:** You only need to do this once per installation

**Safe:** This is a legitimate internal tool, not malware

---

## For Distribution

Include this message when sharing the app:

```
📦 SDK Analyzer Installation

After downloading:

1. Open Terminal
2. Run: xattr -cr ~/Downloads/"SDK Analyzer.app"
3. Double-click the app to use

This one-time step removes the macOS security warning for
unsigned apps. The app is safe - it's an internal tool for
analyzing mobile applications.

Questions? See SECURITY-WORKAROUND.md
```

---

**Bottom Line:** This is a normal macOS security feature, not a real threat. The simple Terminal command fixes it permanently.
