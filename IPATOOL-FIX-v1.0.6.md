# SDK Analyzer v1.0.6 - ipatool Detection Fix

## What Was Fixed

**Problem:** Users got "sh: ipatool: command not found" error when trying to analyze iOS apps

**Root Cause:** The app didn't check if ipatool was installed before attempting Apple ID authentication

**Solution:** Added automatic ipatool detection at the start of iOS analysis

---

## What Happens Now

When users select "iOS (App Store)" and ipatool is NOT installed, they will see:

```
⚠️  Setup Required

ipatool needs to be installed to download iOS apps.

Would you like to:

1. Install automatically (requires Terminal)
2. See installation instructions

[Cancel]  [Show Instructions]  [Install Now]
```

### Option 1: Show Instructions
- Displays step-by-step installation commands
- Copies commands to clipboard
- User can paste in Terminal

### Option 2: Install Now
- Opens Terminal with automated installation script
- Installs Homebrew (if needed)
- Installs ipatool
- Shows success/failure messages
- User returns to SDK Analyzer when done

### Option 3: Cancel
- Exits gracefully
- No confusing error messages

---

## What Users Should Do

### If They Get "ipatool: command not found" Error

This means they're using the OLD version (v1.0.5 or earlier).

**Solution:** Download the latest version from the distribution package

### If They See "Setup Required" Dialog

This means they're using the NEW version (v1.0.6+).

**Instructions:**
1. Choose "Install Now" for easiest setup
2. Follow Terminal prompts
3. Return to SDK Analyzer
4. Try again - authentication will now work

---

## Testing Checklist

✅ Test with ipatool NOT installed:
   - Should show "Setup Required" dialog
   - "Install Now" should open Terminal
   - Installation script should work
   - After install, authentication should work

✅ Test with ipatool ALREADY installed:
   - Should skip directly to authentication check
   - No "Setup Required" dialog
   - Normal authentication flow

---

## For Test Users

**If you previously got the "ipatool: command not found" error:**

1. Get the latest SDK-Analyzer-v1.0.zip
2. Extract and open SDK Analyzer.app
3. Select "iOS (App Store)"
4. You'll see "Setup Required" - choose "Install Now"
5. Follow the Terminal prompts
6. Return to SDK Analyzer
7. Try your App Store URL again
8. Authentication should now work!

---

## Technical Details

**Detection Code:**
```applescript
-- First, check if ipatool is installed
set ipatoolInstalled to false
try
    do shell script "cd " & quoted form of scriptDir & " && export PATH=\"/opt/homebrew/bin:/usr/local/bin:$PATH\" && which ipatool"
    set ipatoolInstalled to true
end try

if not ipatoolInstalled then
    -- Show setup dialog
    ...
end if
```

**Location:** Lines 29-127 of SDK-Analyzer.applescript

**When It Runs:** Immediately when user selects "iOS (App Store)", BEFORE authentication check

---

## Files Changed

- ✅ SDK-Analyzer.applescript (added ipatool detection)
- ✅ SDK Analyzer.app (recompiled with detection)
- ✅ SDK-Analyzer-v1.0.zip (updated distribution)

---

## Version History

**v1.0.6** (Current)
- Added ipatool installation detection
- Added guided installation flow
- Fixed "ipatool: command not found" error

**v1.0.5** (Previous)
- Integrated Apple ID authentication
- Added authentication status check
- Error occurred if ipatool not installed

---

## Success Criteria

Users should NEVER see "sh: ipatool: command not found" anymore.

Instead, they see:
1. Clear "Setup Required" dialog
2. Choice of installation methods
3. Guided installation process
4. Success confirmation
5. Normal authentication flow

---

**Status:** ✅ Fixed in v1.0.6 (current distribution)

**Testing Needed:** Verify with test user who originally reported the issue
