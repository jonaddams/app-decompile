# Repo Reorganization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Split the flat, 30+ file repo into two clearly separated tools — `ios/` (CLI) and `android/` (GUI + CLI) — with one README each, and delete all historical/duplicate markdown.

**Architecture:** Create `ios/` and `android/` subdirectories. Move scripts into them, fix the one path dependency (`competitors.txt`/`library-info.txt` go from `$ORIGINAL_DIR` to `$SCRIPT_DIR/..`). Strip iOS from the AppleScript and recompile the `.app`. Write two focused READMEs plus a minimal root README. Delete ~30 stale files.

**Tech Stack:** bash, AppleScript, osacompile

---

### Task 1: Create directory structure and move iOS files

**Files:**
- Create: `ios/` directory
- Move: `detect-sdk-ios.sh` → `ios/detect-sdk-ios.sh`
- Move: `watch-and-extract-ipa.sh` → `ios/watch-and-extract-ipa.sh`
- Move: `extract-ipa.sh` → `ios/extract-ipa.sh`

**Step 1: Create the ios directory and move scripts**

```bash
mkdir ios
git mv detect-sdk-ios.sh ios/detect-sdk-ios.sh
git mv watch-and-extract-ipa.sh ios/watch-and-extract-ipa.sh
git mv extract-ipa.sh ios/extract-ipa.sh
```

**Step 2: Verify**

```bash
ls ios/
# Expected: detect-sdk-ios.sh  extract-ipa.sh  watch-and-extract-ipa.sh
git status
# Expected: 3 renamed files
```

**Step 3: Commit**

```bash
git commit -m "refactor: move iOS scripts to ios/ subdirectory"
```

---

### Task 2: Fix data file paths in detect-sdk-ios.sh

The script currently resolves `competitors.txt` and `library-info.txt` from `$ORIGINAL_DIR` (the working directory at invocation). From `ios/` that would look in `ios/` instead of the root. Fix by using the script's own location.

**Files:**
- Modify: `ios/detect-sdk-ios.sh` (lines ~35-50 and the `load_library_info` function)

**Step 1: Add SCRIPT_DIR and fix COMPETITORS_FILE**

Find this block near the top of `ios/detect-sdk-ios.sh`:
```bash
# Configuration
ORIGINAL_DIR="${PWD}"
WORK_DIR="${PWD}/sdk-analysis-$(date +%Y%m%d-%H%M%S)"
```

Add `SCRIPT_DIR` immediately after `ORIGINAL_DIR`:
```bash
# Configuration
ORIGINAL_DIR="${PWD}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="${PWD}/sdk-analysis-$(date +%Y%m%d-%H%M%S)"
```

Then find:
```bash
COMPETITORS_FILE="$ORIGINAL_DIR/competitors.txt"
```
Change to:
```bash
COMPETITORS_FILE="$SCRIPT_DIR/../competitors.txt"
```

**Step 2: Fix library-info.txt path in load_library_info()**

Find inside `load_library_info()`:
```bash
LIBRARY_INFO_FILE="$ORIGINAL_DIR/library-info.txt"
```
Change to:
```bash
LIBRARY_INFO_FILE="$SCRIPT_DIR/../library-info.txt"
```

**Step 3: Verify the paths resolve correctly**

```bash
cd ios
bash -n detect-sdk-ios.sh
# Expected: no syntax errors
```

**Step 4: Smoke test (no IPA needed — just help flag)**

```bash
cd ios
./detect-sdk-ios.sh --help
# Expected: help text printed, no errors about missing files
```

**Step 5: Commit**

```bash
git add ios/detect-sdk-ios.sh
git commit -m "fix: resolve competitors.txt and library-info.txt relative to script location in ios/"
```

---

### Task 3: Create android directory and move Android files

**Files:**
- Create: `android/` directory
- Move: `detect-sdk-android.sh` → `android/detect-sdk-android.sh`
- Move: `download-apk-helper.sh` → `android/download-apk-helper.sh`
- Move: `SDK-Analyzer.applescript` → `android/SDK-Analyzer.applescript`
- Move: `SDK Analyzer.app` → `android/SDK Analyzer.app`

**Step 1: Create directory and move files**

```bash
mkdir android
git mv detect-sdk-android.sh android/detect-sdk-android.sh
git mv download-apk-helper.sh android/download-apk-helper.sh
git mv SDK-Analyzer.applescript android/SDK-Analyzer.applescript
git mv "SDK Analyzer.app" "android/SDK Analyzer.app"
```

**Step 2: Verify**

```bash
ls android/
# Expected: SDK Analyzer.app  SDK-Analyzer.applescript  detect-sdk-android.sh  download-apk-helper.sh
git status
# Expected: 4 renamed files
```

**Step 3: Commit**

```bash
git commit -m "refactor: move Android scripts and GUI app to android/ subdirectory"
```

---

### Task 4: Fix data file paths in detect-sdk-android.sh

Same path issue as the iOS script.

**Files:**
- Modify: `android/detect-sdk-android.sh`

**Step 1: Add SCRIPT_DIR**

Find near the top of `android/detect-sdk-android.sh`:
```bash
ORIGINAL_DIR="${PWD}"
```

Add immediately after:
```bash
ORIGINAL_DIR="${PWD}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

**Step 2: Fix COMPETITORS_FILE**

Find:
```bash
COMPETITORS_FILE="$ORIGINAL_DIR/competitors.txt"
```
Change to:
```bash
COMPETITORS_FILE="$SCRIPT_DIR/../competitors.txt"
```

**Step 3: Fix library-info.txt path**

Search for `library-info.txt` in the file:
```bash
grep -n "library-info" android/detect-sdk-android.sh
```

Update any occurrence of `$ORIGINAL_DIR/library-info.txt` to `$SCRIPT_DIR/../library-info.txt`.

**Step 4: Verify**

```bash
cd android
bash -n detect-sdk-android.sh
./detect-sdk-android.sh --help
# Expected: help text, no path errors
```

**Step 5: Commit**

```bash
git add android/detect-sdk-android.sh
git commit -m "fix: resolve competitors.txt and library-info.txt relative to script location in android/"
```

---

### Task 5: Strip iOS from SDK-Analyzer.applescript and recompile

**Files:**
- Modify: `android/SDK-Analyzer.applescript`
- Rebuild: `android/SDK Analyzer.app`

**Step 1: Remove iOS from the welcome dialog**

In `android/SDK-Analyzer.applescript`, find the `on run` handler:
```applescript
set platformChoice to button returned of (display dialog welcomeMessage buttons {"Cancel", "Android (APK)", "iOS (App Store)"} default button "iOS (App Store)" ...)
```
Change to:
```applescript
set platformChoice to button returned of (display dialog welcomeMessage buttons {"Cancel", "Analyze Android App"} default button "Analyze Android App" ...)
```

**Step 2: Remove the iOS dispatch**

Find and delete:
```applescript
if platformChoice is "iOS (App Store)" then
    analyzeIOS()
else if platformChoice is "Android (APK)" then
    analyzeAndroid()
end if
```
Replace with:
```applescript
if platformChoice is "Analyze Android App" then
    analyzeAndroid()
end if
```

**Step 3: Delete the entire analyzeIOS() handler**

Find `-- iOS Analysis Function` and delete from that line through `end analyzeIOS` (approximately lines 19–412 of the original file). The file should retain only `on run`, `analyzeAndroid()`, and any shared helpers.

**Step 4: Recompile the app bundle**

```bash
cd android
osacompile -o "SDK Analyzer.app" "SDK-Analyzer.applescript"
```

Expected: No errors. The existing `SDK Analyzer.app` bundle is replaced.

**Step 5: Verify the app launches and shows only Android option**

```bash
open "android/SDK Analyzer.app"
# Manually verify: dialog shows only "Cancel" and "Analyze Android App"
# Close without running analysis
```

**Step 6: Commit**

```bash
git add "android/SDK-Analyzer.applescript" "android/SDK Analyzer.app"
git commit -m "feat: remove iOS from Android GUI app, Android-only dialog"
```

---

### Task 6: Write ios/README.md

**Files:**
- Create: `ios/README.md`

**Step 1: Write the file**

Content must cover:
1. One-paragraph description of what the iOS tool does
2. **One-time setup** section: `brew install fswatch`, install Apple Configurator 2 (Mac App Store link)
3. **Workflow** (three numbered steps):
   - Step 1: Run `./watch-and-extract-ipa.sh` (leave it running)
   - Step 2: In Apple Configurator 2 — connect iPhone, Actions → Add → Apps, select app, click Add
   - Step 3: Run `./detect-sdk-ios.sh --local-ipa ~/Desktop/extracted-ipas/YourApp.ipa`
4. **Flag reference** for `detect-sdk-ios.sh` (copy from `--help` output, trim to essentials)
5. **Troubleshooting**: ipatool broken note + issue link, "No IPAs found" → use watcher not extract-ipa.sh

Do NOT include: version history, changelog, internal notes, security workarounds, SETUP-HELPER instructions.

**Step 2: Verify the file renders correctly**

```bash
cat ios/README.md | wc -l
# Expected: under 150 lines — if much longer, trim
```

**Step 3: Commit**

```bash
git add ios/README.md
git commit -m "docs: add ios/README.md — single complete iOS tool guide"
```

---

### Task 7: Write android/README.md

**Files:**
- Create: `android/README.md`

**Step 1: Write the file**

Content must cover:
1. One-paragraph description
2. **GUI workflow** (primary, for non-technical users):
   - Open `SDK Analyzer.app`
   - Click "Analyze Android App"
   - Select APK file
   - View results
3. **Getting an APK** section: APKPure link, XAPK support note
4. **CLI workflow** (secondary): `detect-sdk-android.sh` flag reference
5. **Troubleshooting**: common errors (Java not found, APK not found, XAPK handling)

Do NOT include: iOS references, changelog, security workarounds.

**Step 2: Verify length**

```bash
cat android/README.md | wc -l
# Expected: under 150 lines
```

**Step 3: Commit**

```bash
git add android/README.md
git commit -m "docs: add android/README.md — single complete Android tool guide"
```

---

### Task 8: Rewrite root README.md

**Files:**
- Modify: `README.md`

**Step 1: Replace content entirely**

The new root README.md should contain:
1. One-line title: `# SDK Detection Tools`
2. One-paragraph description of what both tools do and why (license compliance)
3. **iOS tool** section: 3-sentence summary + `→ See ios/README.md`
4. **Android tool** section: 3-sentence summary + `→ See android/README.md`
5. **Shared files** section: brief note that `competitors.txt` and `library-info.txt` are used by both tools
6. Legal notice (2–3 sentences, keep from existing)

Target length: 50–70 lines max. No quick-start commands, no flag reference — those live in the per-tool READMEs.

**Step 2: Verify**

```bash
wc -l README.md
# Expected: under 80 lines
```

**Step 3: Commit**

```bash
git add README.md
git commit -m "docs: replace root README with minimal overview linking to ios/ and android/"
```

---

### Task 9: Delete stale files

**Step 1: Delete changelog and historical fix docs**

```bash
git rm \
  BUGFIX-v1.0.1.md BUGFIX-v1.0.2.md \
  UI-IMPROVEMENTS-v1.0.3.md \
  CLEANUP-FEATURE-v1.0.4.md \
  AUTHENTICATION-FEATURE-v1.0.5.md \
  IPATOOL-FIX-v1.0.6.md \
  LATEST-UPDATE-v1.0.7.md GUI-PASSWORD-FIX-v1.0.7.md \
  UPDATE-NOTICE.md \
  APP-TRANSLOCATION-FIX.md \
  SECURITY-FIX-METHODS.md SECURITY-WORKAROUND.md \
  SIMPLE-FIX-GUIDE.md TESTED-FIX-INSTRUCTIONS.md \
  RESPONSE-TO-TESTER.md TEST-RESULTS.md \
  DISTRIBUTION-GUIDE.md IMPORTANT-FILE-STRUCTURE.md
```

**Step 2: Delete consolidated docs (content now in per-tool READMEs)**

```bash
git rm \
  GETTING_STARTED.md README-FIRST.md QUICK-START.md \
  SDK_DETECTION_GUIDE.md USAGE_EXAMPLES.md \
  INSTALLATION-INSTRUCTIONS.md \
  README-GUI.md GUI-App-README.md \
  ANDROID_GUIDE.md \
  APPLE-CONFIGURATOR-GUIDE.md QUICK-START-APPLE-CONFIGURATOR.md \
  STEP-BY-STEP.md
```

**Step 3: Delete misc junk**

```bash
git rm \
  FILES-SUMMARY.txt NON_TECHNICAL_QUICKSTART.txt \
  ANDROID_NON_TECHNICAL_GUIDE.txt ANDROID_SUMMARY.txt \
  xapk-test-output.txt \
  Fix-Security-Warning.command Remove-Quarantine.command \
  SETUP-HELPER.sh \
  SDK-Analyzer-v1.0.zip
```

**Step 4: Delete any committed generated report files**

```bash
# Check if any report .txt files are tracked
git ls-files "*.txt" | grep -E "sdk-detection|framework-analysis|android-sdk"
# If any appear, remove them:
# git rm <filename>
```

**Step 5: Verify nothing important was accidentally removed**

```bash
git status
# Review the deleted files list — should be only the files listed above
ls
# Expected root: README.md  android/  competitors.txt  docs/  ios/  library-info.txt  .gitignore
```

**Step 6: Commit**

```bash
git commit -m "chore: delete 30 stale changelog, historical, and duplicate markdown files"
```

---

### Task 10: Update .gitignore

**Files:**
- Modify: `.gitignore`

**Step 1: Add report output patterns**

Append to `.gitignore`:
```
# Generated analysis reports
sdk-detection-*.txt
framework-analysis-*.txt
android-sdk-detection-*.txt
library-analysis-*.txt
sdk-analysis-*/
```

**Step 2: Verify**

```bash
git check-ignore -v framework-analysis-com-bloomberg-bloomberg-20260218-164513.txt
# Expected: .gitignore:<line>:framework-analysis-*.txt  framework-analysis-...txt
```

**Step 3: Commit**

```bash
git add .gitignore
git commit -m "chore: ignore generated analysis report files"
```

---

### Task 11: Final check and push

**Step 1: Verify repo structure**

```bash
ls -la
# Expected: README.md  android/  competitors.txt  docs/  ios/  library-info.txt  .gitignore

ls ios/
# Expected: README.md  detect-sdk-ios.sh  extract-ipa.sh  watch-and-extract-ipa.sh

ls android/
# Expected: README.md  SDK Analyzer.app  SDK-Analyzer.applescript  detect-sdk-android.sh  download-apk-helper.sh
```

**Step 2: Verify iOS script runs from its subdirectory**

```bash
cd ios && ./detect-sdk-ios.sh --help
# Expected: help output, no errors
cd ..
```

**Step 3: Verify Android script runs from its subdirectory**

```bash
cd android && ./detect-sdk-android.sh --help
# Expected: help output, no errors
cd ..
```

**Step 4: Check commit log looks clean**

```bash
git log --oneline -10
```

**Step 5: Push**

```bash
git push origin main
```
