# SDK Detection Script - Usage Examples

## Quick Start

The scripts automatically generate uniquely named reports for each app you analyze.

**Platforms Supported:**
- 📱 iOS (via `detect-sdk-ios.sh`)
- 🤖 Android (via `detect-sdk-android.sh`) - **Now with XAPK support!**

## Report Naming

**Default behavior**: Reports are automatically named with the app's bundle ID and timestamp:

```
sdk-detection-{bundle-id}-{timestamp}.txt
```

### Examples:

```bash
# Analyzing "Data Collect Mobile" creates:
sdk-detection-com-scenedoc-mobile-ios-20251015-153416.txt

# Analyzing another app creates a different file:
sdk-detection-com-example-pdfviewer-20251015-154523.txt
```

## Common Use Cases

### 1. Check a Single Customer App

```bash
./detect-sdk.sh -s pspdfkit -s nutrient -b com.customer.app
```

**Output**: `sdk-detection-com-customer-app-20251015-150000.txt`

### 2. Check Multiple Customer Apps (Keep All Reports)

```bash
# Customer 1
./detect-sdk.sh -s pspdfkit -b com.customer1.app

# Customer 2
./detect-sdk.sh -s pspdfkit -b com.customer2.app

# Customer 3
./detect-sdk.sh -s pspdfkit -b com.customer3.app
```

**Result**: Three separate report files, all kept in your directory:
- `sdk-detection-com-customer1-app-20251015-150000.txt`
- `sdk-detection-com-customer2-app-20251015-150100.txt`
- `sdk-detection-com-customer3-app-20251015-150200.txt`

### 3. Analyze from App Store URL

```bash
./detect-sdk.sh -s pspdfkit \
  -u https://apps.apple.com/us/app/data-collect-mobile/id1494756647
```

### 4. Search by App Name

```bash
./detect-sdk.sh -s pspdfkit -q "PDF Reader"
```

The script will show search results and let you select which app to analyze.

### 5. Multiple SDKs Detection

Check for multiple SDKs at once (useful after rebrand):

```bash
./detect-sdk.sh -s pspdfkit -s nutrient -s "PSPDFKit" -b com.customer.app
```

## Android-Specific Examples

### 1. Analyze APK File

```bash
./detect-sdk-android.sh -s pspdfkit -s nutrient -f /path/to/app.apk
```

### 2. Analyze XAPK File (Automatic Extraction) 🆕

The easiest way to analyze Android apps! Download the XAPK from APKPure and the script automatically extracts and merges split APKs:

```bash
# Download from APKPure, then:
./detect-sdk-android.sh -s pspdfkit -s nutrient -f app.xapk

# Or with relative path:
./detect-sdk-android.sh -f ~/Downloads/quickbooks.xapk

# List all libraries without searching for specific SDKs:
./detect-sdk-android.sh -f app.xapk
```

**What happens automatically:**
1. ✅ Script detects it's an XAPK file
2. ✅ Extracts the base APK
3. ✅ Extracts and merges architecture-specific libraries (ARM64, x86, etc.)
4. ✅ Merges additional resources
5. ✅ Creates a single APK for analysis
6. ✅ Analyzes all native libraries and Java packages

### 3. List All Libraries (No SDK Search)

Discover what's in an app without specifying SDK names:

```bash
# Lists all 57+ libraries, frameworks, and packages
./detect-sdk-android.sh -f app.xapk
```

### 4. Competitor Detection

The script automatically detects competitor products from `competitors.txt`:

```bash
./detect-sdk-android.sh -f app.xapk
```

**Output includes:**
```
⚠️  COMPETITOR PRODUCTS DETECTED

1. libmodpdfium.so
   Competitor:  PDFium
   Size:        5.0M
```

### 6. Custom Report Name

Override the automatic naming:

```bash
./detect-sdk.sh -s pspdfkit -b com.customer.app -o client-audit-report.txt
```

**Output**: `client-audit-report.txt`

### 7. Keep Analysis Files (No Cleanup)

Preserve the extracted IPA and all files for manual inspection:

```bash
./detect-sdk.sh -s pspdfkit -b com.customer.app --no-cleanup
```

**Result**:
- Report: `sdk-detection-com-customer-app-20251015-150000.txt`
- Analysis folder: `sdk-analysis-20251015-150000/` (kept)

### 8. Verbose Mode for Debugging

See detailed output of what the script is doing:

```bash
./detect-sdk.sh -s pspdfkit -b com.customer.app -v
```

## Batch Analysis Script

Create a script to analyze multiple customers:

```bash
#!/bin/bash
# analyze-customers.sh

# List of customer bundle IDs
CUSTOMERS=(
    "com.customer1.app"
    "com.customer2.app"
    "com.customer3.app"
    "com.customer4.app"
)

# SDKs to check for
SDKS="pspdfkit nutrient"

for bundle_id in "${CUSTOMERS[@]}"; do
    echo "Analyzing $bundle_id..."
    ./detect-sdk.sh -s $SDKS -b "$bundle_id"
    echo "---"
done

echo "All reports generated:"
ls -lh sdk-detection-*.txt
```

Run it:
```bash
chmod +x analyze-customers.sh
./analyze-customers.sh
```

## Organizing Reports

### By Date

```bash
# Create dated folder
mkdir reports-2025-10-15

# Move today's reports
mv sdk-detection-*-20251015-*.txt reports-2025-10-15/
```

### By Customer

```bash
# Organize by customer
mkdir -p reports/customer1
mkdir -p reports/customer2

mv sdk-detection-com-customer1-*.txt reports/customer1/
mv sdk-detection-com-customer2-*.txt reports/customer2/
```

## Reading Reports

### View Summary

```bash
# See if SDK was detected
grep "RESULT:" sdk-detection-*.txt
```

### Get Version Info

```bash
# Extract SDK versions
grep -A 3 "Framework directory detected" sdk-detection-*.txt
```

### List All Analyzed Apps

```bash
# Show all app names from reports
grep "Name:" sdk-detection-*.txt
```

## Interpreting Results

### ✅ SDK Found

```
✅ RESULT: pspdfkit SDK IS PRESENT

  - PSPDFKit.framework (v10.9.2, build 2024.04.12.1601), size: 35M
  - Binary links to pspdfkit framework
```

**Action**: Contact customer about license compliance.

### ❌ SDK Not Found

```
❌ RESULT: pspdfkit SDK NOT DETECTED
```

**Action**: Customer has successfully removed the SDK.

### ⚠️ Mixed Results

If checking multiple SDKs:

```
✅ pspdfkit detected
❌ nutrient NOT detected
```

**Interpretation**: Customer is using the old PSPDFKit SDK, not the rebranded Nutrient SDK.

## Tips

1. **Always check both names after rebrand**: `-s pspdfkit -s nutrient`
2. **Use bundle ID for accuracy**: More reliable than searching by name
3. **Keep reports for compliance**: Date-stamped reports serve as proof of analysis
4. **Batch process at night**: Analyzing many apps takes time (download + analysis)
5. **Check file sizes**: Large frameworks (30+ MB) are harder to miss in audits

## Troubleshooting

### "app not found"
- Verify the bundle ID is correct
- Try searching first: `./detect-sdk.sh -s pspdfkit -q "App Name"`

### "ipatool not authenticated"
```bash
ipatool auth login --email your@email.com
```

### Reports not saving
- Check write permissions in current directory
- Ensure disk space is available

### Want to re-analyze
Just run the script again - timestamps prevent overwriting previous reports.

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: SDK Compliance Check

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday

jobs:
  check-sdks:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2

      - name: Install ipatool
        run: brew install ipatool

      - name: Authenticate
        run: ipatool auth login --email ${{ secrets.APPLE_ID }}

      - name: Run SDK checks
        run: |
          ./detect-sdk.sh -s pspdfkit -b com.customer1.app
          ./detect-sdk.sh -s pspdfkit -b com.customer2.app

      - name: Upload reports
        uses: actions/upload-artifact@v2
        with:
          name: sdk-reports
          path: sdk-detection-*.txt
```

## Support

For issues or questions:
1. Check the main guide: `SDK_DETECTION_GUIDE.md`
2. Run with verbose flag: `-v`
3. Keep analysis files: `--no-cleanup` for manual inspection

---

**Last Updated**: 2025-10-15
