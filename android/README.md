# Android SDK Detection Tool

This tool detects third-party SDKs in Android APKs for license compliance purposes. It can identify whether specific SDKs — such as PSPDFKit or Nutrient document SDKs — are present in an app, and generates a results report. Two interfaces are available: a macOS GUI app (`SDK Analyzer.app`) and a command-line script (`detect-sdk-android.sh`).

## GUI (Recommended)

1. Double-click `SDK Analyzer.app` to open it.
2. Click **"Analyze Android App"**.
3. Select your `.apk` or `.xapk` file.
4. View the results report.

## Getting an APK

- Download from [APKPure](https://apkpure.com) — search by app name and download the `.apk` or `.xapk` file.
- XAPK files are supported — the tool automatically extracts and merges split APKs.
- Or use ADB if a device is connected:
  ```
  adb shell pm path com.example.app
  adb pull <path>
  ```

## CLI

Run `detect-sdk-android.sh` directly for command-line usage.

**Flags:**

| Flag | Description |
|------|-------------|
| `-s, --sdk <name>` | SDK to search for (repeatable) |
| `-f, --file <path>` | Path to APK/XAPK file |
| `-p, --package <id>` | Package name (attempts auto-download) |

**Example:**

```bash
./detect-sdk-android.sh -s pspdfkit -s nutrient -f /path/to/app.apk
```

## Troubleshooting

- **Java not found** — Install Java via `brew install openjdk` or download from https://adoptium.net.
- **XAPK not working** — Make sure you are passing the full `.xapk` file path; the tool handles extraction automatically.
- **App not found by package name** — Use `-f` with a manually downloaded APK instead.
