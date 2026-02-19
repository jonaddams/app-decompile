# SDK Detection Tools

These tools detect whether Nutrient/PSPDFKit SDKs are embedded in mobile apps, for use in verifying license compliance. One tool is for iOS (CLI), one is for Android (GUI + CLI).

## iOS

A CLI tool that analyzes IPA files for embedded Nutrient/PSPDFKit frameworks and binary dependencies. Requires Apple Configurator 2 and fswatch to extract IPAs from the App Store. Runs entirely from the Terminal on macOS.

-> See [ios/README.md](ios/README.md)

## Android

A GUI app (SDK Analyzer.app) plus a CLI shell script for analyzing APK and XAPK files. Open SDK Analyzer.app, select an APK or XAPK, and view detection results in the interface. The CLI script is also available for scripting and batch use.

-> See [android/README.md](android/README.md)

## Shared Files

`competitors.txt` and `library-info.txt` in the repo root are used by both tools to identify known SDKs and competitors.

## Legal

This tool is for legitimate defensive security purposes only, including license compliance verification and detecting unauthorized SDK usage by former customers. Unauthorized reverse engineering, bypassing app protections, or analysis of third-party apps without permission is not allowed. Follow your company's legal procedures for compliance issues and consult legal counsel as needed.
