# Repo Reorganization Design
**Date:** 2026-02-18

## Problem

The repository has grown into a flat directory of 30+ markdown files — versioned changelogs, historical fix guides, duplicate quick-starts, and generated reports — alongside the actual scripts. It is difficult to know what to read or run. iOS and Android are interleaved in both the GUI and docs despite having completely different workflows.

## Goals

1. Two clearly separated tools: `ios/` and `android/`
2. Each tool has exactly one README
3. The GUI (AppleScript app) becomes Android-only
4. All changelog/historical/duplicate markdown deleted
5. Shared data files remain at root, accessible by both tools

## Approved Approach: Subdirectories (Option A)

### Final File Structure

```
ios/
  detect-sdk-ios.sh          # moved + SCRIPT_DIR path fix
  watch-and-extract-ipa.sh   # moved
  extract-ipa.sh             # moved
  README.md                  # new, replaces ~10 iOS docs

android/
  detect-sdk-android.sh      # moved + SCRIPT_DIR path fix
  download-apk-helper.sh     # moved
  SDK-Analyzer.applescript   # moved + iOS section removed
  SDK-Analyzer.app           # moved (recompiled)
  README.md                  # new, replaces ~8 Android docs

competitors.txt              # stays at root (shared)
library-info.txt             # stays at root (shared)
README.md                    # replaces current, brief overview + links
.gitignore                   # updated: ignore generated report .txt files
docs/plans/                  # this design doc
```

### Files Deleted

Versioned changelogs (no ongoing value):
- BUGFIX-v1.0.1.md, BUGFIX-v1.0.2.md
- UI-IMPROVEMENTS-v1.0.3.md
- CLEANUP-FEATURE-v1.0.4.md
- AUTHENTICATION-FEATURE-v1.0.5.md
- IPATOOL-FIX-v1.0.6.md
- LATEST-UPDATE-v1.0.7.md, GUI-PASSWORD-FIX-v1.0.7.md
- UPDATE-NOTICE.md

Historical/superseded fix guides:
- APP-TRANSLOCATION-FIX.md
- SECURITY-FIX-METHODS.md, SECURITY-WORKAROUND.md
- SIMPLE-FIX-GUIDE.md, TESTED-FIX-INSTRUCTIONS.md
- RESPONSE-TO-TESTER.md, TEST-RESULTS.md
- Fix-Security-Warning.command, Remove-Quarantine.command
- SETUP-HELPER.sh (ipatool setup, ipatool is broken)

Consolidated into new per-tool READMEs:
- GETTING_STARTED.md, README-FIRST.md, QUICK-START.md
- SDK_DETECTION_GUIDE.md, USAGE_EXAMPLES.md
- INSTALLATION-INSTRUCTIONS.md, DISTRIBUTION-GUIDE.md
- IMPORTANT-FILE-STRUCTURE.md
- README-GUI.md, GUI-App-README.md
- ANDROID_GUIDE.md, ANDROID_NON_TECHNICAL_GUIDE.txt, ANDROID_SUMMARY.txt
- APPLE-CONFIGURATOR-GUIDE.md, QUICK-START-APPLE-CONFIGURATOR.md
- STEP-BY-STEP.md

Other junk:
- FILES-SUMMARY.txt, NON_TECHNICAL_QUICKSTART.txt
- xapk-test-output.txt
- framework-analysis-*.txt (generated report, should not be committed)
- SDK-Analyzer-v1.0.zip (binary artifact)

## Script Changes

### Path fix (both scripts)

Both `detect-sdk-ios.sh` and `detect-sdk-android.sh` resolve `competitors.txt` and
`library-info.txt` via `$ORIGINAL_DIR` (the shell's working directory at invocation).
Once moved to subdirectories, this breaks. Fix: derive paths from the script's own
location instead.

Change in both scripts:
```bash
# Before
ORIGINAL_DIR="${PWD}"
COMPETITORS_FILE="$ORIGINAL_DIR/competitors.txt"
# (library-info.txt resolved similarly inside load_library_info())

# After
ORIGINAL_DIR="${PWD}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPETITORS_FILE="$SCRIPT_DIR/../competitors.txt"
# load_library_info() updated similarly to use $SCRIPT_DIR/../library-info.txt
```

### AppleScript changes

Remove from `SDK-Analyzer.applescript`:
- The `analyzeIOS()` function (~lines 19–412)
- The iOS button from the welcome dialog (change 3-button to 2-button)
- The `if platformChoice is "iOS (App Store)"` branch

The welcome dialog changes from:
```applescript
{"Cancel", "Android (APK)", "iOS (App Store)"}
```
to:
```applescript
{"Cancel", "Analyze Android App"}
```

Recompile the `.app` bundle from the updated `.applescript`.

## New READMEs

### `ios/README.md`
- One-time setup: Homebrew, fswatch, Apple Configurator 2
- Three-step workflow: run watcher → download via Configurator → analyze
- Full flag reference for `detect-sdk-ios.sh`
- Troubleshooting section

### `android/README.md`
- GUI workflow (primary): open app → select APK → view results
- CLI fallback: `detect-sdk-android.sh` flag reference
- APK acquisition: APKPure/APKMirror guidance
- Troubleshooting section

### `README.md` (root)
- Two-sentence description of what the repo is
- Links to `ios/` and `android/`
- No content duplication

## .gitignore Update

Add patterns to prevent generated reports from being committed:
```
sdk-detection-*.txt
framework-analysis-*.txt
android-sdk-detection-*.txt
sdk-analysis-*/
```
