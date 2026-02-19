# iOS SDK Detection Tool

This tool detects third-party SDKs (such as PSPDFKit/Nutrient document SDKs) inside iOS app bundles, enabling license compliance checks. It works by analyzing IPA files extracted from the App Store. Note that `ipatool` direct downloads have been broken since January 2026 (see [issue #437](https://github.com/majd/ipatool/issues/437)), so Apple Configurator 2 is currently required to obtain IPA files.

## Setup (one-time)

1. Install fswatch:
   ```bash
   brew install fswatch
   ```

2. Install Apple Configurator 2 from the Mac App Store:
   https://apps.apple.com/us/app/apple-configurator/id1037126344

## Usage

**Step 1:** Start the IPA watcher (leave it running in a terminal):

```bash
cd ios && ./watch-and-extract-ipa.sh
```

**Step 2:** In Apple Configurator 2, download the app:

- Connect your iPhone via USB
- Click on the device
- Go to Actions → Add → Apps...
- Search for the app and click Add

The watcher detects the IPA the instant it appears in Apple Configurator's cache and copies it automatically to `~/Desktop/extracted-ipas/`.

**Step 3:** Analyze the extracted IPA:

```bash
./detect-sdk-ios.sh --local-ipa ~/Desktop/extracted-ipas/YourApp.ipa
```

## Options

Flags for `detect-sdk-ios.sh`:

| Flag | Description |
|------|-------------|
| `-s, --sdk <name>` | SDK to search for (repeatable). If omitted, lists all frameworks found. |
| `-l, --local-ipa <path>` | Path to the IPA file (required). |
| `--no-cleanup` | Keep temporary files after analysis. |
| `-v, --verbose` | Verbose output. |

Example — check for PSPDFKit and Nutrient SDKs:

```bash
./detect-sdk-ios.sh -s pspdfkit -s nutrient --local-ipa ~/Desktop/extracted-ipas/App.ipa
```

## Troubleshooting

**"No IPAs found in cache"**

The watcher must be running _before_ you click Add in Apple Configurator 2. Apple Configurator clears its cache quickly after a download completes. If you ran `extract-ipa.sh` after the fact, the cache was already cleared. Always start `watch-and-extract-ipa.sh` first, then trigger the download.

**ipatool is broken**

Direct App Store downloads via ipatool have been broken since January 2026. Track the fix at:
https://github.com/majd/ipatool/issues/437

Once resolved, the `-u` (username), `-b` (bundle ID), and `-i` (item ID) flags will work again for direct downloads without needing Apple Configurator 2.
