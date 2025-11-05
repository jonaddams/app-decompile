# SDK Analyzer - Native SwiftUI App

A native macOS application for analyzing mobile apps to detect SDKs and frameworks.

## Project Setup

1. Open Xcode
2. Create New Project → macOS → App
3. Product Name: `SDK Analyzer`
4. Organization Identifier: `com.yourcompany` (or your preference)
5. Interface: SwiftUI
6. Language: Swift
7. Save in this directory

## Architecture

```
SDK Analyzer.app/
├── Contents/
│   ├── MacOS/
│   │   └── SDK Analyzer (executable)
│   └── Resources/
│       ├── detect-sdk-ios.sh
│       ├── detect-sdk-android.sh
│       ├── competitors.txt
│       └── library-info.txt
```

## Key Features

- **Native UI**: Proper forms, progress bars, cancellation
- **Bundled Resources**: Scripts embedded in app bundle
- **Secure Input**: Native password fields
- **Real Progress**: Actual progress tracking from shell output
- **Error Handling**: Clear, actionable error messages
- **Code Signable**: Ready for Developer ID signing

## Files to Create

1. `SDKAnalyzerApp.swift` - App entry point
2. `ContentView.swift` - Main view with platform selection
3. `IOSAnalysisView.swift` - iOS analysis flow
4. `AndroidAnalysisView.swift` - Android analysis flow
5. `AuthenticationView.swift` - Apple ID authentication
6. `ProgressView.swift` - Analysis progress display
7. `ShellScriptRunner.swift` - Shell script execution helper
8. `Models.swift` - Data models

## Next Steps

See the individual .swift files in this directory for the complete implementation.
