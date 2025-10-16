# Getting Started - For Non-Technical Users

## What Does This Tool Do?

This tool checks if a former customer's iOS app still contains your SDK (software library). It's useful for verifying license compliance after a customer relationship ends.

## What You Need

1. **A Mac computer** (This tool only works on macOS)
2. **An Apple ID** (The same one you use for the App Store)
3. **The app's App Store URL or bundle ID** (We'll show you how to find this)

That's it! The tool will install everything else automatically.

## Step-by-Step Instructions

### Step 1: Download the Tool

1. Download all the files to a folder on your Mac
2. Open **Terminal** (Applications → Utilities → Terminal)
3. Type `cd ` (with a space after it)
4. Drag the folder containing the script into Terminal
5. Press Enter

You should see something like:
```
cd /Users/yourname/Downloads/app-decompile
```

### Step 2: Make the Script Runnable

In Terminal, type:
```bash
chmod +x detect-sdk.sh
```

Press Enter. This only needs to be done once.

### Step 3: Find the App Information

You need either the **App Store URL** or **Bundle ID** of the app you want to check.

#### Option A: Using the App Store URL (Easiest)

1. Open the **App Store** on your Mac or iPhone
2. Find the customer's app
3. Click the **Share** button
4. Select **Copy Link**

The link will look like:
```
https://apps.apple.com/us/app/app-name/id1234567890
```

**Note:** The tool automatically handles URLs with extra parameters, so all these work:
- `https://apps.apple.com/us/app/app-name/id1234567890`
- `https://apps.apple.com/us/app/app-name/id1234567890?l=es-MX`
- `https://apps.apple.com/gb/app/app-name/id1234567890?mt=8&uo=4`

Just paste the URL as-is - no need to clean it up!

#### Option B: Using the Bundle ID

The bundle ID is the app's unique identifier, like `com.company.appname`. You can:
- Search for it on [AppFollow](https://appfollow.io/)
- Search for it on [App Store](https://www.apple.com/app-store/)
- Ask the customer (if appropriate)

### Step 4: Run the Analysis

In Terminal, type one of these commands:

**Using App Store URL:**
```bash
./detect-sdk.sh -s pspdfkit -s nutrient -u "https://apps.apple.com/us/app/app-name/id1234567890"
```

**Using Bundle ID:**
```bash
./detect-sdk.sh -s pspdfkit -s nutrient -b com.company.appname
```

Replace:
- `pspdfkit` and `nutrient` with your SDK names
- The URL or bundle ID with the actual app information

### Step 5: First-Time Setup (Automatic)

When you run the script for the first time, it will automatically:

1. **Install Homebrew** (if you don't have it)
   - You may be asked for your Mac password
   - This is normal and safe

2. **Install ipatool** (if you don't have it)
   - This happens automatically via Homebrew

3. **Ask for your Apple ID**
   - Enter your Apple ID email
   - Enter your Apple ID password
   - Enter the 2FA code if prompted (check your iPhone/iPad)

The script guides you through each step with clear messages.

### Step 6: Wait for Analysis

The script will:
1. ✅ Download the app from the App Store (~45 MB typical)
2. ✅ Extract and analyze the app
3. ✅ Search for your SDK
4. ✅ Generate a report

This takes 2-5 minutes depending on app size and internet speed.

### Step 7: Read the Results

When done, you'll see a message like:
```
✅ RESULT: pspdfkit SDK IS PRESENT
```

or

```
❌ RESULT: pspdfkit SDK NOT DETECTED
```

The full report is saved as:
```
sdk-detection-com-company-appname-20251015-153416.txt
```

## Understanding the Results

### ✅ SDK Found (Red Flag)

```
✅ RESULT: pspdfkit SDK IS PRESENT

  - PSPDFKit.framework (v10.9.2, build 2024.04.12.1601), size: 35M
  - Binary links to pspdfkit framework
```

**What this means:**
- The customer's app **still contains** your SDK
- They have **NOT** removed it
- This may be a license compliance issue

**What to do:**
1. Open the report file (double-click it)
2. Note the SDK version and size
3. Contact the customer about license compliance
4. Save the report for your records

### ❌ SDK Not Found (All Clear)

```
❌ RESULT: pspdfkit SDK NOT DETECTED
```

**What this means:**
- The customer's app does **NOT** contain your SDK
- They **HAVE** successfully removed it
- No compliance issues

### ⚠️ Mixed Results

```
✅ pspdfkit detected
❌ nutrient NOT detected
```

**What this means:**
- They're using the old SDK name (PSPDFKit)
- They haven't updated to the new name (Nutrient)
- The SDK is still present

## Common Issues & Solutions

### "Permission denied"

**Solution:** You forgot Step 2. Run:
```bash
chmod +x detect-sdk.sh
```

### "Command not found"

**Solution:** You're not in the right folder. Make sure you did Step 1 correctly.

### "App not found"

**Solution:**
- Check the bundle ID is correct
- Try searching: `./detect-sdk.sh -s pspdfkit -q "App Name"`

### Script asks for password

**Normal!** Your Mac password is needed to install Homebrew. This is safe and standard.

### Authentication keeps failing

**Solutions:**
1. Make sure you're using the correct Apple ID
2. Check your 2FA code is still valid (they expire quickly)
3. Try generating an app-specific password at [appleid.apple.com](https://appleid.apple.com)

## Analyzing Multiple Customers

To check multiple apps, just run the script multiple times:

```bash
# Customer 1
./detect-sdk.sh -s pspdfkit -b com.customer1.app

# Customer 2
./detect-sdk.sh -s pspdfkit -b com.customer2.app

# Customer 3
./detect-sdk.sh -s pspdfkit -b com.customer3.app
```

Each analysis creates a separate report with a unique name:
- `sdk-detection-com-customer1-app-20251015-150000.txt`
- `sdk-detection-com-customer2-app-20251015-150100.txt`
- `sdk-detection-com-customer3-app-20251015-150200.txt`

## Tips for Non-Technical Users

1. **Keep Terminal open** - Don't close it while the script is running
2. **Be patient** - Downloading and analyzing takes a few minutes
3. **Save the reports** - Keep them as proof of your compliance check
4. **Copy commands carefully** - Terminal is very precise about spacing and spelling
5. **Ask for help** - If stuck, ask a technical colleague to help with Terminal

## Example: Complete First Run

Here's what you'll see on your first run:

```
========================================
Checking Requirements
========================================

ℹ️  Homebrew not found. Installing Homebrew...

[Homebrew installation happens]

✅ Homebrew installed successfully
ℹ️  ipatool not found. Installing ipatool via Homebrew...
✅ ipatool installed successfully
⚠️  ipatool is not authenticated

You need to authenticate with your Apple ID to download apps.

Enter your Apple ID email: you@example.com
ℹ️  Authenticating with Apple ID: you@example.com

[You enter your password]
[You enter your 2FA code]

✅ Successfully authenticated with Apple ID
✅ All required tools found

========================================
Downloading App
========================================

ℹ️  Downloading app with bundle ID: com.customer.app
[Progress bar]
✅ Downloaded app.ipa (45M)

========================================
SDK Detection
========================================

Searching for: pspdfkit
🔍 FOUND: Framework directory detected
  📦 PSPDFKit.framework
     Version: 10.9.2
     Size: 35M

✅ RESULT: pspdfkit SDK IS PRESENT

========================================
Analysis Complete
========================================

✅ Detected SDKs: pspdfkit

📄 Full report: /Users/you/Downloads/app-decompile/sdk-detection-com-customer-app-20251015-153416.txt
```

## What to Include in Your Compliance Report

When reporting findings to management or legal:

1. **App Information**
   - App name
   - Company name
   - Bundle ID
   - Version number

2. **SDK Detection Results**
   - Was SDK found? (Yes/No)
   - SDK version
   - SDK size (how much of their app is your code)
   - Detection date

3. **Supporting Evidence**
   - Attach the generated report file
   - Screenshot of the App Store page

4. **Recommendation**
   - Contact customer to discuss license
   - Request SDK removal
   - Propose license renewal if appropriate

## Need Help?

- **For technical issues**: See [SDK_DETECTION_GUIDE.md](SDK_DETECTION_GUIDE.md)
- **For usage examples**: See [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md)
- **For general info**: See [README.md](README.md)

## Glossary

- **Terminal**: A text-based interface for running commands on your Mac
- **Script**: An automated program (like `detect-sdk.sh`)
- **SDK**: Software Development Kit - a library of code used by developers
- **Bundle ID**: A unique identifier for an app (like `com.apple.safari`)
- **Framework**: A package of code (SDKs are distributed as frameworks)
- **Homebrew**: A tool for installing software on Mac
- **ipatool**: A tool for downloading apps from the App Store
- **IPA**: The file format for iOS apps (like .exe on Windows)

---

**Remember**: This tool is for legitimate license compliance verification only. Use responsibly and ethically.
