# iOS SDK Detection Tool

This tool detects third-party SDKs (such as PSPDFKit/Nutrient document SDKs) inside iOS app bundles, enabling license compliance checks. It analyzes an IPA downloaded from the App Store.

> **Note on the framework name:** the Nutrient SDK still ships under its legacy name **`PSPDFKit`** (`PSPDFKit.framework`, `PSPDFKitUI.framework`). Always search for `pspdfkit` — a `nutrient`-only search will miss real usage.

## Quick path (recommended): ipatool

`ipatool` downloads the IPA directly from the App Store. This is the fast, reliable path — no Apple Configurator, no cache-watching.

> The old warning that `ipatool` downloads were "broken since January 2026 (#437)" was a **stale/auth-state issue, not a real breakage**. Once `ipatool` is authenticated, downloads work. Verified 2026-07-10 on macOS/Apple Silicon with ipatool 2.3.1.

### Setup (one-time)

```bash
brew install ipatool
ipatool auth login -e <your-apple-id-email>   # completes 2FA; session persists across runs
```

### Usage

```bash
# 1. Find the bundle ID
ipatool search "Acronis Cyber Files"
#    → {"bundleID":"com.grouplogic.mobilecho","id":429704844, ...}

# 2. Download the IPA (--purchase acquires a free-app license inline if needed)
ipatool download -b com.grouplogic.mobilecho \
  -o ~/Desktop/extracted-ipas/AcronisCyberFiles.ipa --purchase

# 3. Detect the SDK
./detect-sdk-ios.sh -s pspdfkit -s nutrient \
  --local-ipa ~/Desktop/extracted-ipas/AcronisCyberFiles.ipa
```

Detection works on the encrypted App Store IPA — framework bundle names and dynamic-library linkage (`otool`) are readable without decryption.

### Check the current session

```bash
ipatool auth info   # success=true means you're ready to download
```

If a download 401s or auth looks stale, run `ipatool auth login` again to mint a fresh token.

## Detection options

Flags for `detect-sdk-ios.sh`:

| Flag | Description |
|------|-------------|
| `-s, --sdk <name>` | SDK to search for (repeatable). If omitted, lists all frameworks found. |
| `-l, --local-ipa <path>` | Path to the IPA file (required). |
| `--no-cleanup` | Keep temporary files after analysis. |
| `-v, --verbose` | Verbose output. |

Example — check for PSPDFKit and Nutrient:

```bash
./detect-sdk-ios.sh -s pspdfkit -s nutrient --local-ipa ~/Desktop/extracted-ipas/App.ipa
```

The report (framework names, versions, sizes, linkage evidence) is written to `sdk-detection-<bundle-id>-<timestamp>.txt`.

## Last resort: Apple Configurator 2

Only if `ipatool` is unavailable. **Be aware this path is now often blocked for consumer Apple IDs** — Apple has steered Configurator app downloads toward Apple Business Manager / managed IDs. In testing it failed even with a healthy account (`401 Unauthorized` in Add → Apps, then `AMSErrorDomain error 100` on sign-in). Try `ipatool` first.

1. `brew install fswatch`, install Apple Configurator 2 from the Mac App Store.
2. Start the watcher (leave running): `cd ios && ./watch-and-extract-ipa.sh`
3. In Configurator: connect iPhone → select device → **Actions → Add → Apps…** → search → **Add**. The watcher copies the IPA to `~/Desktop/extracted-ipas/` the instant it appears.
4. Analyze with `./detect-sdk-ios.sh --local-ipa ~/Desktop/extracted-ipas/YourApp.ipa`.

**Troubleshooting Configurator:** an empty `extracted-ipas/` almost always means the download never actually happened (stale Apple ID session), not a watcher bug. Quit Configurator, `pkill -f "[c]onfigurator.xpc"`, reopen, sign out and back in (complete 2FA), then retry. If it still 401s / throws AMS 100, the account is likely not eligible for Configurator downloads — use `ipatool`.
