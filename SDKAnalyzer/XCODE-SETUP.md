# SDK Analyzer - Xcode Project Setup Guide

This guide walks you through creating the Xcode project and building the native macOS app.

---

## Prerequisites

- **macOS Ventura or later**
- **Xcode 14.0 or later** (Download from Mac App Store if needed)
- Basic familiarity with Xcode (we'll walk you through it!)

---

## Step 1: Create New Xcode Project

1. **Open Xcode**

2. **Create a new project:**
   - Click "Create a new Xcode project" or File → New → Project
   - Select **macOS** tab at the top
   - Choose **App** template
   - Click **Next**

3. **Configure the project:**
   - **Product Name:** `SDK Analyzer`
   - **Team:** Select your Apple ID (or leave as "None" for testing)
   - **Organization Identifier:** `com.yourcompany` (or any reverse domain)
   - **Bundle Identifier:** Will auto-populate as `com.yourcompany.SDK-Analyzer`
   - **Interface:** **SwiftUI**
   - **Language:** **Swift**
   - **Storage:** None
   - **Include Tests:** Uncheck both boxes (not needed)
   - Click **Next**

4. **Save the project:**
   - Navigate to: `/Users/jonaddamsnutrient/SE/app-decompile/`
   - Click **Create**

---

## Step 2: Add Swift Files to Project

You'll replace the default file and add the new ones.

### 2.1 Replace Default App File

1. **In Xcode's left sidebar (Project Navigator):**
   - Find `SDK_AnalyzerApp.swift` (default name with underscore)
   - Delete it (Right-click → Delete → Move to Trash)

2. **Add the new app file:**
   - Right-click on the `SDK Analyzer` folder (blue icon)
   - Select **Add Files to "SDK Analyzer"...**
   - Navigate to `/Users/jonaddamsnutrient/SE/app-decompile/SDKAnalyzer/`
   - Select `SDKAnalyzerApp.swift`
   - Make sure **"Copy items if needed"** is checked
   - Click **Add**

### 2.2 Add All Other Swift Files

Repeat the "Add Files" process for each file:

1. Right-click on `SDK Analyzer` folder → **Add Files to "SDK Analyzer"...**
2. Select **all** these files at once (hold Cmd and click each):
   - `Models.swift`
   - `ShellScriptRunner.swift`
   - `ContentView.swift`
   - `IOSAnalysisView.swift`
   - `AndroidAnalysisView.swift`
3. Make sure **"Copy items if needed"** is checked
4. Click **Add**

### 2.3 Remove Default ContentView (if exists)

If Xcode created a default `ContentView.swift`:
- Delete it (Right-click → Delete → Move to Trash)
- We're using our custom one instead

**Your Project Navigator should now show:**
```
SDK Analyzer
├── SDKAnalyzerApp.swift
├── Models.swift
├── ShellScriptRunner.swift
├── ContentView.swift
├── IOSAnalysisView.swift
├── AndroidAnalysisView.swift
└── Assets.xcassets
```

---

## Step 3: Add Shell Scripts to Bundle

The app needs access to the shell scripts at runtime.

### 3.1 Add Scripts Folder

1. **In Project Navigator:**
   - Right-click on `SDK Analyzer` folder
   - Select **New Group**
   - Name it `Scripts`

2. **Add shell scripts to the project:**
   - Right-click on the new `Scripts` group
   - Select **Add Files to "SDK Analyzer"...**
   - Navigate to `/Users/jonaddamsnutrient/SE/app-decompile/`
   - Select these files (hold Cmd):
     - `detect-sdk-ios.sh`
     - `detect-sdk-android.sh`
     - `competitors.txt`
     - `library-info.txt`
   - **IMPORTANT:** Make sure **"Copy items if needed"** is checked
   - Click **Add**

### 3.2 Configure Scripts as Bundle Resources

1. **Click on the project name** at the top of Project Navigator (blue icon)

2. **Select the "SDK Analyzer" target** (not the project)

3. **Go to "Build Phases" tab**

4. **Expand "Copy Bundle Resources"**

5. **Verify these files are listed:**
   - `detect-sdk-ios.sh`
   - `detect-sdk-android.sh`
   - `competitors.txt`
   - `library-info.txt`

6. **If any are missing:**
   - Click the **+** button
   - Select the missing files
   - Click **Add**

### 3.3 Make Scripts Executable

Add a build phase to make scripts executable:

1. **Still in "Build Phases" tab:**
   - Click **+** button at top left
   - Select **New Run Script Phase**

2. **Drag the new "Run Script"** phase to be **after** "Copy Bundle Resources"

3. **Expand the "Run Script" phase**

4. **In the script box, paste:**
   ```bash
   #!/bin/bash
   # Make bundled shell scripts executable

   SCRIPTS_DIR="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Resources"

   chmod +x "${SCRIPTS_DIR}/detect-sdk-ios.sh"
   chmod +x "${SCRIPTS_DIR}/detect-sdk-android.sh"

   echo "Made scripts executable"
   ```

5. **Name the phase** (optional but helpful):
   - Click on "Run Script" title
   - Rename to: "Make Scripts Executable"

---

## Step 4: Configure App Permissions

The app needs permissions to access files and network.

### 4.1 Update App Sandbox Settings

1. **Select the project** in Project Navigator

2. **Select "SDK Analyzer" target**

3. **Go to "Signing & Capabilities" tab**

4. **Add App Sandbox** (if not already present):
   - Click **+ Capability**
   - Select **App Sandbox**

5. **Configure permissions:**
   - **File Access:**
     - ✅ User Selected File: **Read Only**
   - **Network:**
     - ✅ Outgoing Connections (Client)
   - **Downloads Folder Access:** (Optional but recommended)
     - ✅ Downloads Folder: **Read/Write**

### 4.2 Add Info.plist Entries

1. **In Project Navigator:**
   - Find `Info.plist` (or click on project → Info tab)

2. **Add these keys** (Right-click in the list → Add Row):

   **Network Usage:**
   - **Key:** `NSAppTransportSecurity`
   - **Type:** Dictionary
     - Add child key: `NSAllowsArbitraryLoads`
     - Type: Boolean
     - Value: YES

   **File Access Description:**
   - **Key:** `NSAppleEventsUsageDescription`
   - **Type:** String
   - **Value:** `SDK Analyzer needs to run scripts to analyze mobile applications.`

---

## Step 5: Configure Build Settings

### 5.1 Set Deployment Target

1. **Select project** in Project Navigator
2. **Select "SDK Analyzer" target**
3. **Go to "Build Settings" tab**
4. **Search for "macOS Deployment Target"**
5. **Set to:** `13.0` (macOS Ventura)

### 5.2 Configure Product Name

1. **Still in Build Settings**
2. **Search for "Product Name"**
3. **Verify it's set to:** `SDK Analyzer` (with space, not underscore)

---

## Step 6: Build and Test

### 6.1 First Build

1. **Select build destination:**
   - In toolbar, next to "SDK Analyzer" target
   - Select **My Mac**

2. **Build the project:**
   - Press **⌘B** (Command + B)
   - Or: Product → Build

3. **Fix any errors** (should build successfully)

### 6.2 Run the App

1. **Run in Xcode:**
   - Press **⌘R** (Command + R)
   - Or: Product → Run

2. **Test the app:**
   - Should see platform selection screen
   - Click "iOS (App Store)" or "Android (APK)"
   - Verify UI appears correctly

---

## Step 7: Code Signing (Optional but Recommended)

Code signing prevents security warnings for users.

### Option 1: Sign with Personal Apple ID (Free)

1. **In Xcode → Settings → Accounts:**
   - Click **+** button
   - Add your Apple ID

2. **Back in project:**
   - Select "Signing & Capabilities" tab
   - Check **"Automatically manage signing"**
   - Select your **Team** (your Apple ID)

3. **Build again** - Xcode will sign the app

### Option 2: Developer ID Signing ($99/year)

For distribution outside the Mac App Store:

1. **Enroll in Apple Developer Program** ($99/year)
   - https://developer.apple.com/programs/

2. **Create Developer ID Application certificate**

3. **In Xcode:**
   - Uncheck "Automatically manage signing"
   - Select your Developer ID certificate

### Option 3: Skip Signing (Testing Only)

If you're just testing:
- Uncheck "Automatically manage signing"
- Set Team to "None"
- App will run but will show security warnings when distributed

---

## Step 8: Export the App

Once built successfully, export for distribution.

### 8.1 Archive the App

1. **In Xcode menu:**
   - Product → Archive

2. **Wait for archive to complete**

3. **Organizer window opens automatically**

### 8.2 Export Without Signing (For Testing)

1. **In Organizer:**
   - Select your archive
   - Click **Distribute App**

2. **Select distribution method:**
   - Choose **Copy App**
   - Click **Next**

3. **Choose destination:**
   - Select a folder (e.g., Desktop)
   - Click **Export**

4. **Your app is now at:** `~/Desktop/SDK Analyzer.app`

### 8.3 Export with Signing (For Distribution)

1. **Follow 8.1 to create archive**

2. **In Organizer:**
   - Click **Distribute App**
   - Select **Developer ID**
   - Follow prompts to sign and notarize

---

## Step 9: Test the Exported App

### 9.1 Remove Quarantine (If Needed)

If you didn't sign the app:

```bash
xattr -cr ~/Desktop/SDK\ Analyzer.app
```

### 9.2 Run the App

1. **Double-click** `SDK Analyzer.app`

2. **If security warning appears:**
   - System Settings → Privacy & Security
   - Click "Open Anyway"

3. **Test both platforms:**
   - iOS analysis with App Store URL
   - Android analysis with APK file

---

## Troubleshooting

### Build Errors

**Error: "Cannot find 'Platform' in scope"**
- Make sure all .swift files are added to target
- Check Project Navigator → select file → right panel → Target Membership

**Error: "No such module 'SwiftUI'"**
- Update macOS Deployment Target to 13.0 or later
- Build Settings → macOS Deployment Target

### Runtime Errors

**Error: "Could not find analysis script"**
- Verify scripts are in "Copy Bundle Resources" (Build Phases)
- Verify "Make Scripts Executable" run script exists
- Clean build folder: Product → Clean Build Folder

**App shows security warning:**
- See Step 7 for code signing
- Or use: `xattr -cr "SDK Analyzer.app"`

**Permission denied errors:**
- Check App Sandbox permissions (Step 4.1)
- Make sure scripts have execute permissions

---

## Project Structure

After setup, your project should look like:

```
SDK Analyzer/
├── SDK Analyzer.xcodeproj
├── SDK Analyzer/
│   ├── SDKAnalyzerApp.swift          ← Entry point
│   ├── Models.swift                   ← Data structures
│   ├── ShellScriptRunner.swift        ← Script execution
│   ├── ContentView.swift              ← Platform selection
│   ├── IOSAnalysisView.swift          ← iOS analysis UI
│   ├── AndroidAnalysisView.swift      ← Android analysis UI
│   ├── Assets.xcassets                ← App icon
│   ├── Info.plist                     ← Permissions
│   └── Scripts/                       ← Shell scripts
│       ├── detect-sdk-ios.sh
│       ├── detect-sdk-android.sh
│       ├── competitors.txt
│       └── library-info.txt
```

---

## Next Steps

Once the app builds and runs successfully:

1. **Customize the app icon:**
   - Add icon to Assets.xcassets/AppIcon

2. **Test thoroughly:**
   - Test iOS authentication flow
   - Test Android APK analysis
   - Verify reports open correctly

3. **Package for distribution:**
   - Create DMG or ZIP
   - Include documentation
   - Sign and notarize (if distributing)

4. **Consider enhancements:**
   - Add app icon and branding
   - Add "About" window with version info
   - Add preferences for temporary file management
   - Add recent files list

---

## Need Help?

### Common Issues:

**Q: Scripts not found at runtime**
A: Check "Copy Bundle Resources" includes all .sh and .txt files

**Q: Permission denied when running scripts**
A: Verify "Make Scripts Executable" run script is present and runs after copying resources

**Q: App crashes on launch**
A: Check Xcode console for error messages, verify all Swift files are added to target

**Q: Authentication fails for iOS**
A: Ensure network permissions are enabled in App Sandbox, check Homebrew and ipatool are installed

---

## Building From Command Line (Optional)

If you prefer command-line builds:

```bash
# Build
xcodebuild -project "SDK Analyzer.xcodeproj" \
  -scheme "SDK Analyzer" \
  -configuration Release \
  build

# Archive
xcodebuild -project "SDK Analyzer.xcodeproj" \
  -scheme "SDK Analyzer" \
  -configuration Release \
  -archivePath "./build/SDK Analyzer.xcarchive" \
  archive

# Export
xcodebuild -exportArchive \
  -archivePath "./build/SDK Analyzer.xcarchive" \
  -exportPath "./build" \
  -exportOptionsPlist ExportOptions.plist
```

---

**You're all set! Build the app and enjoy a native macOS experience.** 🎉
