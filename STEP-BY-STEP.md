# Step-by-Step: Extract Your First IPA

## What You Need to Do Right Now

### Step 1: Install Apple Configurator 2 ⬅️ **YOU ARE HERE**

The Mac App Store should have just opened.

1. **Find "Apple Configurator 2"** in the App Store
2. **Click "Get"** (or "Install" if you see that)
3. **Wait for download** (~50 MB, takes ~1 minute)
4. **Come back here when installed**

---

### Step 2: Open Apple Configurator 2

Once installed:

```bash
# Option 1: Via command line
open -a "Apple Configurator 2"

# Option 2: Via Spotlight
# Press Cmd+Space, type "Apple Configurator", press Enter
```

**First time setup:**
- You may be asked to sign in with your Apple ID → **Sign in**
- Grant permissions if requested → **Allow**

---

### Step 3: Make Sure Your iPhone is Connected & Trusted

1. **Check USB connection** - iPhone should be connected to Mac
2. **Unlock your iPhone**
3. **Look at iPhone screen** - if you see "Trust This Computer?" → Tap **"Trust"**
4. **Enter iPhone passcode** if asked
5. **Look in Apple Configurator 2** - you should see your device appear

**Troubleshooting:**
- If device doesn't appear: unplug and replug USB cable
- If "Trust" prompt doesn't appear: disconnect, restart iPhone, reconnect

---

### Step 4: Download the App (This Creates the IPA)

**In Apple Configurator 2:**

1. **Click on your device icon** (your iPhone should be visible)
2. **Click "Actions" menu** (at the top of the screen)
3. **Select "Add"** → **"Apps..."**
4. **Sign in with Apple ID** (if prompted)
   - Use the same Apple ID that's signed in on your iPhone
   - Or any Apple ID that has downloaded this app before

5. **Search for the app** you want to analyze
   - Type the app name in the search box
   - You should see it in the results

6. **Select the app** (click on it)
7. **Click "Add"** button

8. **Wait for download** (~30 seconds to 2 minutes)
   - You'll see a progress bar
   - The IPA is being downloaded to your Mac
   - **IMPORTANT:** Even if the app is already on your iPhone, this downloads a fresh copy to your Mac

---

### Step 5: Extract the IPA Immediately

**The moment the download completes in Apple Configurator:**

```bash
cd /Users/jonaddamsnutrient/SE/app-decompile
./extract-ipa.sh
```

You should see:
```
✅ Found 1 IPA file(s) in cache:
   [filename and size]

✅ Successfully copied IPA(s)!
```

**Why immediately?** Apple Configurator auto-deletes cached IPAs after a while.

---

### Step 6: Analyze the IPA

```bash
# List all frameworks
./detect-sdk-ios.sh --local-ipa ~/Desktop/extracted-ipas/[YourApp].ipa

# Or search for specific SDKs
./detect-sdk-ios.sh --sdk pspdfkit --sdk nutrient --local-ipa ~/Desktop/extracted-ipas/[YourApp].ipa
```

Replace `[YourApp]` with the actual IPA filename.

---

## 🎯 Quick Command Reference

```bash
# 1. Open Apple Configurator
open -a "Apple Configurator 2"

# 2. (Use GUI to download app - see Step 4 above)

# 3. Extract IPA
cd /Users/jonaddamsnutrient/SE/app-decompile
./extract-ipa.sh

# 4. Analyze
./detect-sdk-ios.sh --local-ipa ~/Desktop/extracted-ipas/*.ipa
```

---

## ❓ Common Questions

**Q: The app is already on my iPhone. Why do I need to download it again?**
A: Installing on your iPhone doesn't give you the IPA file. Apple Configurator downloads the IPA to your Mac's cache, which we then extract.

**Q: Can I download multiple apps at once?**
A: Yes! In Step 4, select multiple apps before clicking "Add". Then run `extract-ipa.sh` once to get all of them.

**Q: Do I need to keep the app on my iPhone?**
A: No. Once you've extracted the IPA to `~/Desktop/extracted-ipas/`, you can delete the app from your iPhone.

**Q: Can I use someone else's iPhone?**
A: Yes, as long as:
- The app is available in that iPhone's region
- You can sign into Apple Configurator with an Apple ID that has downloaded the app before

**Q: What if the app isn't free?**
A: You need to use an Apple ID that has purchased the app. Apple Configurator respects App Store purchases.

---

## 🚨 If Something Goes Wrong

### "No device found in Apple Configurator"
→ Unplug iPhone, restart it, plug back in, unlock it

### "Could not find Apple Configurator 2"
→ Install from Mac App Store: `open "macappstore://apps.apple.com/us/app/apple-configurator/id1037126344"`

### "No IPAs found in cache" (after Step 4)
→ You didn't complete Step 4. Go back and use Apple Configurator to actually download the app.

### "App not available"
→ The app might not be in your region. Try a different app or different Apple ID.

---

## ✅ You'll Know It Worked When...

1. **In Apple Configurator:** You see a download progress bar complete
2. **When running `extract-ipa.sh`:** You see "✅ Found 1 IPA file(s)"
3. **In Finder:** You see the IPA at `~/Desktop/extracted-ipas/AppName.ipa`
4. **When analyzing:** You get a detailed framework report

---

**Next:** Once you've installed Apple Configurator 2, come back to **Step 2** above!
