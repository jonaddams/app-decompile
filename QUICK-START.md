# 🚀 Quick Start Guide - SDK Analyzer

## For Non-Technical Users

### Step 1: Open the Application
Double-click **`SDK Analyzer.app`**

### Step 2: Choose Platform
A window will appear asking you to choose:
- **iOS (App Store)** - for iPhone/iPad apps
- **Android (APK)** - for Android apps

### Step 3: Provide App Information

**If you chose iOS:**
1. Paste the App Store link
   - Example: `https://apps.apple.com/us/app/example/id1234567890`
   - How to get it: Open App Store → Find app → Share → Copy Link
2. Click "Analyze"

**If you chose Android:**
1. Browse to your APK file
2. Select it and click "Open"

### Step 4: Wait for Analysis
- A notification will show when analysis starts
- This may take 1-3 minutes depending on app size
- Be patient! The app is downloading and analyzing

### Step 5: View Results
- When complete, a success dialog will appear
- Click "Open Report" to view the analysis
- Report shows all frameworks, libraries, and competitor products

---

## First-Time Setup (iOS Only)

**⚠️ IMPORTANT**: Before analyzing iOS apps for the first time:

1. Open **Terminal** (in Applications → Utilities)
2. Copy and paste this command:
   ```
   ipatool auth login --email your@email.com
   ```
   (Replace `your@email.com` with your Apple ID)
3. Press Enter and type your Apple ID password
4. This only needs to be done once!

---

## 📍 Where to Find Your Reports

Reports are saved in the same folder as the app:
- Look for files starting with `framework-analysis-` or `library-analysis-`
- They're text files you can open with any text editor
- Each report includes a timestamp in the filename

---

## ❓ Common Issues

### "Authentication Error" (iOS)
**Problem**: Your Apple ID login expired
**Solution**: Run the ipatool auth command again (see First-Time Setup above)

### "Download Error" (iOS)
**Problem**: Can't download the app
**Why**: The app must be:
- Previously downloaded/installed on one of your devices, OR
- Available in your country's App Store

**Solution**: Try with a free app you've already installed on your iPhone

### "App Won't Open"
**Problem**: macOS blocks the app
**Solution**:
1. Right-click the app → Choose "Open"
2. Click "Open" in the warning dialog
3. Or go to System Preferences → Security & Privacy → Click "Open Anyway"

### "Permission Denied"
**Problem**: Scripts don't have permission to run
**Solution**: Ask your IT administrator or technical contact to run:
```bash
chmod +x detect-sdk-ios.sh detect-sdk-android.sh
```

---

## 💡 Tips

1. **Keep everything together**: Don't move `SDK Analyzer.app` without also moving the other files
2. **Internet required**: iOS analysis downloads apps from the App Store
3. **Be patient**: Large apps take longer to analyze
4. **Check notifications**: Look for notifications in the top-right corner of your screen

---

## 📞 Need Help?

Contact your technical administrator or refer to:
- **Detailed Guide**: See `GUI-App-README.md`
- **Command Line Help**: For advanced users only

---

## ✅ What This Tool Does

- Analyzes mobile apps to find what frameworks and libraries they use
- Detects competitor products (like PDF libraries)
- Generates detailed reports for compliance and security review
- Works completely offline (after downloading the app)
- Does not send any data to external servers

**Enjoy analyzing!** 🎉
