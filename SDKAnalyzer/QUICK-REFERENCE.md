# SDK Analyzer Native App - Quick Reference

**TL;DR:** Everything you need to build and run the native macOS app.

---

## 🚀 Quick Start (5 Minutes)

### 1. Open Xcode and Create Project
```
File → New → Project
Choose: macOS → App
Name: SDK Analyzer
Interface: SwiftUI
Language: Swift
Save to: /Users/jonaddamsnutrient/SE/app-decompile/
```

### 2. Add All Swift Files
Delete default `SDK_AnalyzerApp.swift`, then add:
- `SDKAnalyzerApp.swift`
- `Models.swift`
- `ShellScriptRunner.swift`
- `ContentView.swift`
- `IOSAnalysisView.swift`
- `AndroidAnalysisView.swift`

**Right-click project folder → Add Files → Select all → Copy items if needed**

### 3. Bundle Shell Scripts
Add to project (copy items if needed):
- `detect-sdk-ios.sh`
- `detect-sdk-android.sh`
- `competitors.txt`
- `library-info.txt`

**Check:** Build Phases → Copy Bundle Resources (should list all 4 files)

### 4. Make Scripts Executable
Build Phases → + → New Run Script Phase

Paste:
```bash
#!/bin/bash
SCRIPTS_DIR="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Resources"
chmod +x "${SCRIPTS_DIR}/detect-sdk-ios.sh"
chmod +x "${SCRIPTS_DIR}/detect-sdk-android.sh"
```

### 5. Configure Permissions
Signing & Capabilities → App Sandbox:
- ✅ User Selected File: Read Only
- ✅ Outgoing Connections (Client)

### 6. Build and Run
- Press **⌘B** to build
- Press **⌘R** to run
- Test both iOS and Android flows

**Done!** 🎉

---

## 📁 File Overview

| File | Purpose | Lines |
|------|---------|-------|
| `SDKAnalyzerApp.swift` | App entry point | 15 |
| `Models.swift` | Data structures | 40 |
| `ShellScriptRunner.swift` | Script execution engine | 150 |
| `ContentView.swift` | Platform selection UI | 80 |
| `IOSAnalysisView.swift` | iOS analysis flow | 420 |
| `AndroidAnalysisView.swift` | Android analysis flow | 290 |

**Total:** ~1,000 lines of clean SwiftUI code

---

## 🏗️ Architecture

```
┌─────────────────────────────────────┐
│        SDKAnalyzerApp              │
│         (Entry Point)               │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│          ContentView                │
│     (Platform Selection)            │
└──────────────┬──────────────────────┘
               │
       ┌───────┴───────┐
       ▼               ▼
┌─────────────┐  ┌──────────────┐
│IOSAnalysis  │  │AndroidAnalysis│
│    View     │  │     View      │
└──────┬──────┘  └───────┬───────┘
       │                 │
       └────────┬────────┘
                ▼
    ┌──────────────────────┐
    │  ShellScriptRunner   │
    │   (Script Engine)    │
    └──────────┬───────────┘
               │
               ▼
    ┌──────────────────────┐
    │   Bundled Scripts    │
    │  (Shell Scripts)     │
    └──────────────────────┘
```

---

## 🎯 Key Components

### ShellScriptRunner
**Purpose:** Execute bundled shell scripts with real-time output

**Main Methods:**
```swift
// Find bundled script
scriptPath(named: "detect-sdk-ios") -> String?

// Run script asynchronously
runScript(
    script: String,
    arguments: [String],
    environment: [String: String]?,
    outputHandler: (String) -> Void,
    completion: (Result<String, Error>) -> Void
)

// Authenticate ipatool
authenticateIPATool(
    email: String,
    password: String,
    authCode: String?,
    outputHandler: (String) -> Void,
    completion: (Result<String, Error>) -> Void
)

// Check if authenticated
checkIPAToolAuth(completion: (String?) -> Void)
```

### AnalysisProgress (Model)
**Purpose:** Track analysis state reactively

**States:**
```swift
enum AnalysisState {
    case idle              // Ready for input
    case authenticating    // Logging into Apple ID
    case downloading       // Downloading app from store
    case analyzing         // Running analysis
    case completed         // Success!
    case failed(Error)     // Something went wrong
}
```

**Properties:**
```swift
@Published var state: AnalysisState
@Published var currentStep: String
@Published var output: String
```

### IOSAnalysisView
**Purpose:** Complete iOS app analysis workflow

**Features:**
- Authentication check on appear
- GUI password/2FA input (native SecureField)
- Real-time progress display
- Output log with ScrollView
- Report opening
- Cleanup prompt

**State:**
```swift
@State private var email = ""
@State private var password = ""
@State private var twoFACode = ""
@State private var appStoreURL = ""
@State private var isAuthenticated = false
@State private var needs2FA = false
@State private var reportPath: String?
@State private var workDirectory: String?
```

### AndroidAnalysisView
**Purpose:** Android APK analysis workflow

**Features:**
- Native file picker (.apk only)
- Progress with output log
- Report opening
- Cleanup prompt

**State:**
```swift
@State private var selectedAPKPath: String?
@State private var reportPath: String?
@State private var workDirectory: String?
```

---

## 🔑 Key Patterns

### Reactive State Management
```swift
@StateObject private var progress = AnalysisProgress()

// Update triggers UI refresh
progress.updateState(.downloading)
progress.appendOutput(output)
```

### Asynchronous Script Execution
```swift
ShellScriptRunner.shared.runScript(
    script: scriptPath,
    arguments: ["-u", url],
    outputHandler: { output in
        // Real-time updates (background thread)
        progress.appendOutput(output)
    },
    completion: { result in
        // Final result (background thread)
        DispatchQueue.main.async {
            // Update UI on main thread
            progress.updateState(.completed)
        }
    }
)
```

### Modal Sheets for Authentication
```swift
.sheet(isPresented: $showingAuthSheet) {
    AuthenticationSheet(
        email: $email,
        password: $password,
        needs2FA: $needs2FA
    )
}
```

### Finding Bundled Resources
```swift
// ShellScriptRunner finds bundled scripts
guard let scriptPath = ShellScriptRunner.shared.scriptPath(named: "detect-sdk-ios") else {
    // Handle error
    return
}

// scriptPath is now: /path/to/SDK Analyzer.app/Contents/Resources/detect-sdk-ios.sh
```

---

## 🐛 Common Issues & Fixes

### Build Errors

**"Cannot find 'Platform' in scope"**
```
Fix: Select each .swift file → File Inspector →
     Check "SDK Analyzer" under Target Membership
```

**"No such module 'SwiftUI'"**
```
Fix: Build Settings → macOS Deployment Target → 13.0
```

### Runtime Errors

**"Could not find analysis script"**
```
Fix: Build Phases → Copy Bundle Resources →
     Add all .sh and .txt files
```

**"Permission denied" when running scripts**
```
Fix: Build Phases → Verify "Make Scripts Executable"
     run script exists and runs AFTER Copy Bundle Resources
```

**Authentication fails**
```
Fix: Signing & Capabilities → App Sandbox →
     Enable "Outgoing Connections (Client)"
```

---

## 📝 Testing Checklist

### Basic Functionality
- [ ] App launches without crash
- [ ] Platform selection shows both options
- [ ] iOS button navigates to iOS view
- [ ] Android button navigates to Android view
- [ ] Back buttons return to platform selection

### iOS Flow
- [ ] Shows authentication status on load
- [ ] App Store URL input works
- [ ] Analyze button disabled when URL empty
- [ ] Authentication sheet appears if not authenticated
- [ ] SecureField hides password
- [ ] Authentication succeeds with valid credentials
- [ ] 2FA prompt appears if needed
- [ ] 2FA code submission works
- [ ] Analysis starts after authentication
- [ ] Progress view shows during analysis
- [ ] Output log displays in real-time
- [ ] Report opens when complete
- [ ] Cleanup button removes temp files
- [ ] "Analyze Another App" resets state

### Android Flow
- [ ] File picker opens on "Select APK File"
- [ ] Only .apk files shown in picker
- [ ] Selected file displays with filename
- [ ] "Change" button allows re-selection
- [ ] Analyze button disabled when no file selected
- [ ] Analysis starts with valid APK
- [ ] Progress view shows during analysis
- [ ] Output log displays in real-time
- [ ] Report opens when complete
- [ ] Cleanup button removes temp files
- [ ] "Analyze Another APK" resets state

### Error Handling
- [ ] Invalid URL shows error
- [ ] Invalid credentials show error
- [ ] Invalid 2FA code shows error
- [ ] Invalid APK shows error
- [ ] Network errors show appropriate message
- [ ] Script errors show appropriate message
- [ ] "Try Again" button resets state

---

## 🚢 Distribution Options

### Option 1: Simple App (Testing)
```bash
# Build in Xcode
Product → Archive → Distribute App → Copy App

# Remove quarantine
xattr -cr "SDK Analyzer.app"

# Zip for distribution
zip -r SDK-Analyzer-v2.0.zip "SDK Analyzer.app"
```

### Option 2: Signed App (Recommended)
```bash
# In Xcode:
# 1. Signing & Capabilities → Team → Select Apple ID
# 2. Product → Archive
# 3. Distribute App → Developer ID
# 4. Follow signing/notarization prompts

# Result: Signed app with no security warnings
```

### Option 3: DMG (Professional)
```bash
# Create DMG with create-dmg tool
brew install create-dmg

create-dmg \
  --volname "SDK Analyzer" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "SDK Analyzer.app" 175 120 \
  --hide-extension "SDK Analyzer.app" \
  --app-drop-link 425 120 \
  "SDK-Analyzer-v2.0.dmg" \
  "SDK Analyzer.app"
```

---

## 🎨 Customization Ideas

### Add App Icon
1. Create 1024x1024 PNG icon
2. Assets.xcassets → AppIcon → Drag icon
3. Build and icon appears everywhere

### Add About Window
```swift
// In ContentView or new AboutView
.sheet(isPresented: $showingAbout) {
    VStack {
        Text("SDK Analyzer")
            .font(.largeTitle)
        Text("Version 2.0")
        Text("© 2025 Your Company")
    }
    .padding()
}
```

### Add Preferences
```swift
// Store user preferences
@AppStorage("skipCleanupPrompt") private var skipCleanup = false
@AppStorage("autoOpenReports") private var autoOpen = true
```

### Add Menu Bar Items
```swift
@main
struct SDKAnalyzerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About SDK Analyzer") {
                    // Show about window
                }
            }
        }
    }
}
```

---

## 📊 Performance Tips

### Reduce Memory Usage
```swift
// Limit output buffer size
func appendOutput(_ newOutput: String) {
    let maxLength = 50000
    output.append(newOutput)
    if output.count > maxLength {
        output = String(output.suffix(maxLength))
    }
}
```

### Improve Responsiveness
```swift
// Update UI less frequently for large outputs
private var lastUpdate = Date()
outputHandler: { output in
    if Date().timeIntervalSince(lastUpdate) > 0.1 {
        DispatchQueue.main.async {
            progress.appendOutput(output)
        }
        lastUpdate = Date()
    }
}
```

---

## 🔗 Useful Resources

### Documentation
- [XCODE-SETUP.md](XCODE-SETUP.md) - Complete setup guide
- [MIGRATION-GUIDE.md](MIGRATION-GUIDE.md) - AppleScript → SwiftUI transition
- [README.md](README.md) - Architecture overview

### Apple Documentation
- [SwiftUI](https://developer.apple.com/documentation/swiftui/)
- [Process](https://developer.apple.com/documentation/foundation/process)
- [App Sandbox](https://developer.apple.com/documentation/security/app_sandbox)

### Tools
- [Xcode](https://developer.apple.com/xcode/)
- [SF Symbols](https://developer.apple.com/sf-symbols/) - For icons
- [create-dmg](https://github.com/create-dmg/create-dmg) - For DMG creation

---

## 💡 Pro Tips

1. **Use Xcode's Preview** - Add `#Preview` to views for live UI development
2. **Enable Debugging** - Product → Scheme → Edit Scheme → Run → Arguments → Add `-com.apple.CoreData.SQLDebug 1`
3. **Test on Fresh Mac** - Use a VM or friend's Mac to test first-run experience
4. **Version Bundled Scripts** - Add version check in scripts for debugging
5. **Log Everything** - Use `print()` liberally, check Console.app for logs
6. **Sign Early** - Get code signing set up early to test real distribution experience

---

## 🎯 Next Steps

1. **Build the app** - Follow [XCODE-SETUP.md](XCODE-SETUP.md)
2. **Test thoroughly** - Use checklist above
3. **Sign and distribute** - Choose distribution method
4. **Gather feedback** - Test with real users
5. **Iterate** - Improve based on feedback

---

**Need Help?**

- Check [XCODE-SETUP.md](XCODE-SETUP.md) for detailed steps
- Check [MIGRATION-GUIDE.md](MIGRATION-GUIDE.md) for architecture details
- Check Xcode Console for error messages
- Check Console.app for runtime logs

---

**You're ready to build! Let's do this.** 🚀
