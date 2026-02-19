#!/bin/bash

################################################################################
# Android App SDK Detection Script
#
# Description: Automates the process of downloading and analyzing Android apps
#              to detect the presence of specific SDKs or libraries.
#
# Usage: ./detect-sdk-android.sh [OPTIONS]
#
# Author: Created for SDK license compliance verification
# Version: 1.0
################################################################################

set -e  # Exit on error

# Add Homebrew to PATH (needed when running from GUI apps)
# Check both Apple Silicon and Intel Mac locations
if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration
ORIGINAL_DIR="${PWD}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="${PWD}/sdk-analysis-android-$(date +%Y%m%d-%H%M%S)"
SDK_NAMES=()
PLAY_STORE_URL=""
PACKAGE_NAME=""
APK_FILE=""
OUTPUT_REPORT="sdk-detection-report.txt"
CLEANUP=true
VERBOSE=false
LIST_ALL_LIBRARIES=false
COMPETITORS_FILE="$SCRIPT_DIR/../competitors.txt"
COMPETITOR_PRODUCTS=()

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "\n${BOLD}${CYAN}========================================${NC}"
    echo -e "${BOLD}${CYAN}$1${NC}"
    echo -e "${BOLD}${CYAN}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_found() {
    echo -e "${MAGENTA}🔍 FOUND: $1${NC}"
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}[DEBUG] $1${NC}"
    fi
}

################################################################################
# Usage and Help
################################################################################

show_usage() {
    cat << EOF
${BOLD}Android App SDK Detection Script${NC}

${BOLD}USAGE:${NC}
    $0 [OPTIONS]

${BOLD}OPTIONS:${NC}
    -s, --sdk <name>          SDK name to search for (can be used multiple times)
                              Example: -s pspdfkit -s nutrient
                              Note: If not specified, all libraries will be listed

    -a, --list-all            List all libraries and SDKs (default if no -s specified)

    -u, --url <url>           Google Play Store URL
                              Example: https://play.google.com/store/apps/details?id=com.example.app

    -p, --package <id>        Package name (bundle identifier)
                              Example: com.example.app

    -f, --file <path>         Path to existing APK or XAPK file to analyze
                              (XAPK files are automatically extracted and merged)

    -o, --output <file>       Output report file (default: auto-generated with app name)

    -w, --work-dir <dir>      Working directory for analysis (default: auto-generated)

    --no-cleanup              Don't delete temporary files after analysis

    -v, --verbose             Enable verbose output

    -h, --help                Show this help message

${BOLD}EXAMPLES:${NC}
    # List all libraries in an APK
    $0 -f /path/to/app.apk

    # Analyze app from Play Store URL for specific SDKs
    $0 -s pspdfkit -s nutrient -u "https://play.google.com/store/apps/details?id=com.example.app"

    # List all libraries using package name
    $0 -p com.example.app

    # Analyze existing APK file for specific SDK
    $0 -s pspdfkit -f /path/to/app.apk

    # List all libraries with verbose output and keep files
    $0 -a -p com.example.app -v --no-cleanup

${BOLD}APK DOWNLOAD METHODS:${NC}
    This script supports multiple methods to obtain APKs:

    1. Provide existing APK file (-f flag)
    2. Download from third-party sources (APKPure, APKMirror)
    3. Extract from connected Android device using ADB

    Note: Google does not provide official API for Play Store downloads.

${BOLD}REQUIREMENTS:${NC}
    - macOS or Linux
    - Java JDK (for apktool)
    - Internet connection (for downloads)
    - Optional: Android device + ADB (for device extraction)

EOF
}

################################################################################
# Validation Functions
################################################################################

install_homebrew() {
    print_info "Homebrew not found. Installing Homebrew..."
    echo ""

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ $(uname -m) == 'arm64' ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    if command -v brew &> /dev/null; then
        print_success "Homebrew installed successfully"
    else
        print_error "Homebrew installation failed"
        exit 1
    fi
}

install_apktool() {
    print_info "apktool not found. Installing apktool via Homebrew..."

    if ! brew install apktool; then
        print_error "Failed to install apktool"
        echo ""
        echo "Please try manually:"
        echo "  $ brew install apktool"
        exit 1
    fi

    print_success "apktool installed successfully"
}

check_java() {
    if ! command -v java &> /dev/null; then
        print_warning "Java not found. apktool requires Java."
        echo ""
        echo "Installing Java via Homebrew..."
        brew install openjdk

        # Link Java
        if [[ $(uname -m) == 'arm64' ]]; then
            sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk 2>/dev/null || true
        else
            sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk 2>/dev/null || true
        fi

        print_success "Java installed"
    else
        log_verbose "Java: found"
    fi
}

check_requirements() {
    print_header "Checking Requirements"

    # Check for Homebrew (macOS only)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &> /dev/null; then
            install_homebrew
        else
            log_verbose "Homebrew: found"
            print_success "Homebrew is installed"
        fi
    fi

    # Check for Java
    check_java

    # Check for apktool
    if ! command -v apktool &> /dev/null; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            install_apktool
        else
            print_error "apktool not found"
            echo ""
            echo "Please install apktool:"
            echo "  - Ubuntu/Debian: sudo apt-get install apktool"
            echo "  - Arch: sudo pacman -S android-apktool"
            echo "  - Or download from: https://ibotpeaches.github.io/Apktool/"
            exit 1
        fi
    else
        log_verbose "apktool: found"
        print_success "apktool is installed"
    fi

    # Check for other required commands
    local missing_tools=()
    for cmd in unzip grep find strings; do
        if ! command -v $cmd &> /dev/null; then
            missing_tools+=("$cmd")
        else
            log_verbose "$cmd: found"
        fi
    done

    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        exit 1
    fi

    print_success "All required tools found"
}

validate_inputs() {
    # If no SDK names provided, enable list all mode
    if [ ${#SDK_NAMES[@]} -eq 0 ]; then
        LIST_ALL_LIBRARIES=true
        log_verbose "No specific SDKs specified - will list all libraries"
    fi

    # Check that at least one app identifier is provided
    if [ -z "$PLAY_STORE_URL" ] && [ -z "$PACKAGE_NAME" ] && [ -z "$APK_FILE" ]; then
        print_error "Must provide one of: --url, --package, or --file"
        echo ""
        show_usage
        exit 1
    fi
}

################################################################################
# APK Acquisition Functions
################################################################################

extract_package_from_url() {
    local url="$1"
    # Extract package name from Play Store URL
    # Example: https://play.google.com/store/apps/details?id=com.example.app
    local package=$(echo "$url" | grep -oE 'id=[^&]+' | cut -d'=' -f2)

    if [ -z "$package" ]; then
        print_error "Could not extract package name from URL: $url"
        echo ""
        echo "Please provide a valid Play Store URL."
        echo "Example: https://play.google.com/store/apps/details?id=com.example.app"
        exit 1
    fi

    echo "$package"
}

download_apk_apkpure() {
    local package="$1"
    local output_file="$2"

    print_info "Attempting to download APK from APKPure..."

    # APKPure download URL format
    local apkpure_url="https://d.apkpure.com/b/APK/${package}?version=latest"

    if curl -L -o "$output_file" "$apkpure_url" 2>/dev/null; then
        # Verify it's actually an APK
        if file "$output_file" | grep -q "Zip archive data"; then
            print_success "Downloaded APK from APKPure"
            return 0
        fi
    fi

    return 1
}

download_apk_device() {
    local package="$1"
    local output_file="$2"

    # Check if ADB is available
    if ! command -v adb &> /dev/null; then
        return 1
    fi

    print_info "Attempting to extract APK from connected Android device..."

    # Check if device is connected
    if ! adb devices | grep -q "device$"; then
        print_warning "No Android device connected via ADB"
        return 1
    fi

    # Get APK path on device
    local apk_path=$(adb shell pm path "$package" 2>/dev/null | cut -d':' -f2 | tr -d '\r')

    if [ -z "$apk_path" ]; then
        print_warning "Package $package not found on connected device"
        return 1
    fi

    # Pull APK from device
    if adb pull "$apk_path" "$output_file" &>/dev/null; then
        print_success "Extracted APK from Android device"
        return 0
    fi

    return 1
}

load_library_info() {
    LIBRARY_INFO_FILE="$SCRIPT_DIR/../library-info.txt"

    if [ ! -f "$LIBRARY_INFO_FILE" ]; then
        log_verbose "Library info database not found: $LIBRARY_INFO_FILE"
        return 1
    fi

    log_verbose "Loaded library information database"
    return 0
}

get_library_description() {
    local lib_name="$1"

    if [ ! -f "$LIBRARY_INFO_FILE" ]; then
        echo ""
        return
    fi

    # Search for library in database (case-insensitive)
    local result=$(grep -i "^${lib_name}|" "$LIBRARY_INFO_FILE" | head -1)

    if [ -n "$result" ]; then
        # Extract description (second field)
        echo "$result" | cut -d'|' -f2
    else
        echo ""
    fi
}

get_library_vendor() {
    local lib_name="$1"

    if [ ! -f "$LIBRARY_INFO_FILE" ]; then
        echo ""
        return
    fi

    # Search for library in database (case-insensitive)
    local result=$(grep -i "^${lib_name}|" "$LIBRARY_INFO_FILE" | head -1)

    if [ -n "$result" ]; then
        # Extract vendor (third field)
        echo "$result" | cut -d'|' -f3
    else
        echo ""
    fi
}

extract_library_versions() {
    local meta_inf_dir="$APK_RAW_PATH/META-INF"

    if [ ! -d "$meta_inf_dir" ]; then
        log_verbose "META-INF directory not found"
        return
    fi

    log_verbose "Extracting library versions from META-INF..."

    # Find all .version files
    LIBRARY_VERSIONS=()
    while IFS= read -r version_file; do
        if [ -f "$version_file" ]; then
            local lib_name=$(basename "$version_file" .version)
            local version=$(cat "$version_file" 2>/dev/null | tr -d '\n\r')

            if [ -n "$version" ]; then
                LIBRARY_VERSIONS+=("$lib_name|$version")
            fi
        fi
    done < <(find "$meta_inf_dir" -name "*.version" 2>/dev/null)

    log_verbose "Found ${#LIBRARY_VERSIONS[@]} library versions"
}

get_library_version() {
    local search_name="$1"

    for version_entry in "${LIBRARY_VERSIONS[@]}"; do
        local lib_name=$(echo "$version_entry" | cut -d'|' -f1)
        local version=$(echo "$version_entry" | cut -d'|' -f2)

        # Check if the library name matches (case-insensitive partial match)
        if echo "$lib_name" | grep -iq "$search_name"; then
            echo "$version"
            return
        fi
    done

    echo ""
}

################################################################################
# Additional Metadata Extraction Functions
################################################################################

extract_play_services_versions() {
    # Initialize global associative array
    PLAY_SERVICES_VERSIONS=()

    log_verbose "Extracting Google Play Services versions..."

    # Find all play-services and firebase .properties files and store in indexed array
    while IFS= read -r prop_file; do
        if [ -f "$prop_file" ]; then
            local version=$(grep "^version=" "$prop_file" 2>/dev/null | cut -d'=' -f2)
            local client=$(grep "^client=" "$prop_file" 2>/dev/null | cut -d'=' -f2)

            if [ -n "$client" ] && [ -n "$version" ]; then
                PLAY_SERVICES_VERSIONS+=("$client|$version")
            fi
        fi
    done < <(find "$APK_RAW_PATH" -name "play-services-*.properties" -o -name "firebase-*.properties" 2>/dev/null)

    log_verbose "Found ${#PLAY_SERVICES_VERSIONS[@]} Play Services/Firebase libraries"
}

extract_androidx_libraries() {
    ANDROIDX_LIBRARIES=()

    log_verbose "Extracting AndroidX library list..."

    local meta_inf_dir="$APK_RAW_PATH/META-INF"

    if [ ! -d "$meta_inf_dir" ]; then
        return
    fi

    # Find all AndroidX .version files
    while IFS= read -r version_file; do
        if [ -f "$version_file" ]; then
            local lib_name=$(basename "$version_file" .version)
            local version=$(cat "$version_file" 2>/dev/null | tr -d '\n\r')

            if [ -n "$version" ] && [[ "$lib_name" == androidx.* ]]; then
                ANDROIDX_LIBRARIES+=("$lib_name|$version")
            fi
        fi
    done < <(find "$meta_inf_dir" -name "androidx.*.version" 2>/dev/null)

    log_verbose "Found ${#ANDROIDX_LIBRARIES[@]} AndroidX libraries"
}

extract_permissions() {
    APP_PERMISSIONS=()
    APP_FEATURES=()

    log_verbose "Extracting permissions and features..."

    local manifest="$APK_EXTRACTED_PATH/AndroidManifest.xml"

    if [ ! -f "$manifest" ]; then
        return
    fi

    # Extract permissions
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            local perm=$(echo "$line" | sed -n 's/.*android:name="\([^"]*\)".*/\1/p')
            if [ -n "$perm" ]; then
                APP_PERMISSIONS+=("$perm")
            fi
        fi
    done < <(grep "uses-permission" "$manifest" 2>/dev/null)

    # Extract features
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            local feat=$(echo "$line" | sed -n 's/.*android:name="\([^"]*\)".*/\1/p')
            local required=$(echo "$line" | sed -n 's/.*android:required="\([^"]*\)".*/\1/p')
            if [ -n "$feat" ]; then
                if [ "$required" = "false" ]; then
                    APP_FEATURES+=("$feat|optional")
                else
                    APP_FEATURES+=("$feat|required")
                fi
            fi
        fi
    done < <(grep "uses-feature" "$manifest" 2>/dev/null)

    log_verbose "Found ${#APP_PERMISSIONS[@]} permissions and ${#APP_FEATURES[@]} features"
}

extract_build_info() {
    BUILD_INFO=()

    log_verbose "Extracting build information..."

    local metadata_file="$APK_RAW_PATH/META-INF/com/android/build/gradle/app-metadata.properties"

    if [ -f "$metadata_file" ]; then
        while IFS='=' read -r key value; do
            if [ -n "$key" ] && [ -n "$value" ]; then
                BUILD_INFO+=("$key|$value")
            fi
        done < "$metadata_file"
    fi

    log_verbose "Found ${#BUILD_INFO[@]} build metadata entries"
}

extract_kotlin_info() {
    KOTLIN_INFO=()

    log_verbose "Extracting Kotlin metadata..."

    # Check for Kotlin tooling metadata
    local kotlin_json="$APK_RAW_PATH/kotlin-tooling-metadata.json"
    if [ -f "$kotlin_json" ]; then
        KOTLIN_INFO+=("metadata_found|yes")
    fi

    # Check for Kotlin libraries in META-INF versions
    local meta_inf_dir="$APK_RAW_PATH/META-INF"
    if [ -d "$meta_inf_dir" ]; then
        while IFS= read -r version_file; do
            if [ -f "$version_file" ]; then
                local lib_name=$(basename "$version_file" .version)
                local version=$(cat "$version_file" 2>/dev/null | tr -d '\n\r')

                if [ -n "$version" ]; then
                    if [[ "$lib_name" == "kotlin"* ]] || [[ "$lib_name" == "kotlinx"* ]]; then
                        KOTLIN_INFO+=("$lib_name|$version")
                    fi
                fi
            fi
        done < <(find "$meta_inf_dir" -name "kotlin*.version" 2>/dev/null)
    fi

    log_verbose "Found ${#KOTLIN_INFO[@]} Kotlin metadata entries"
}

extract_assets_summary() {
    ASSETS_INFO=()

    log_verbose "Extracting assets and resources summary..."

    # Count assets
    local asset_count="0"
    local asset_size="0"
    if [ -d "$APK_RAW_PATH/assets" ]; then
        asset_count=$(find "$APK_RAW_PATH/assets" -type f 2>/dev/null | wc -l | tr -d ' ')
        asset_size=$(du -sh "$APK_RAW_PATH/assets" 2>/dev/null | cut -f1)
    fi
    ASSETS_INFO+=("asset_count|$asset_count")
    ASSETS_INFO+=("asset_size|$asset_size")

    # Count resources
    local res_count="0"
    local res_size="0"
    if [ -d "$APK_RAW_PATH/res" ]; then
        res_count=$(find "$APK_RAW_PATH/res" -type f 2>/dev/null | wc -l | tr -d ' ')
        res_size=$(du -sh "$APK_RAW_PATH/res" 2>/dev/null | cut -f1)
    fi
    ASSETS_INFO+=("res_count|$res_count")
    ASSETS_INFO+=("res_size|$res_size")

    # Detect supported languages from resource qualifiers
    if [ -d "$APK_RAW_PATH/res" ]; then
        local languages=$(find "$APK_RAW_PATH/res" -type d -name "values-*" 2>/dev/null | \
            sed 's/.*values-//' | sed 's/-.*//' | sort -u | tr '\n' ',' | sed 's/,$//')
        if [ -n "$languages" ]; then
            ASSETS_INFO+=("languages|$languages")
        fi
    fi

    log_verbose "Assets: $asset_count files, Resources: $res_count files"
}

process_xapk() {
    local xapk_file="$1"
    local output_apk="$2"

    log_verbose "Processing XAPK file: $xapk_file"

    # Create temporary directory for XAPK extraction
    local xapk_temp="$WORK_DIR/xapk-temp"
    mkdir -p "$xapk_temp"

    # Extract XAPK (it's just a ZIP file)
    log_verbose "Extracting XAPK..."
    if ! unzip -q "$xapk_file" -d "$xapk_temp" 2>/dev/null; then
        print_error "Failed to extract XAPK file"
        rm -rf "$xapk_temp"
        return 1
    fi

    # Find the base APK
    local base_apk=$(find "$xapk_temp" -name "*.apk" -type f ! -name "config.*" | head -1)
    if [ -z "$base_apk" ]; then
        print_error "No base APK found in XAPK"
        rm -rf "$xapk_temp"
        return 1
    fi

    log_verbose "Found base APK: $(basename $base_apk)"

    # Create merge directory
    local merge_dir="$WORK_DIR/merged-apk"
    rm -rf "$merge_dir"
    mkdir -p "$merge_dir"

    # Extract base APK
    log_verbose "Extracting base APK..."
    if ! unzip -q "$base_apk" -d "$merge_dir" 2>/dev/null; then
        print_error "Failed to extract base APK"
        rm -rf "$xapk_temp" "$merge_dir"
        return 1
    fi

    # Find and merge architecture-specific APKs (contains native libraries)
    local arch_apks=$(find "$xapk_temp" -name "config.arm*.apk" -o -name "config.x86*.apk" 2>/dev/null)

    if [ -n "$arch_apks" ]; then
        print_info "Merging architecture-specific libraries..."
        echo "$arch_apks" | while IFS= read -r arch_apk; do
            if [ -n "$arch_apk" ] && [ -f "$arch_apk" ]; then
                log_verbose "Merging: $(basename $arch_apk)"
                unzip -o -q "$arch_apk" -d "$merge_dir" 2>/dev/null || true
            fi
        done
        print_success "Architecture libraries merged"
    fi

    # Find and merge language/resource config APKs
    local config_apks=$(find "$xapk_temp" -name "config.*.apk" ! -name "config.arm*" ! -name "config.x86*" 2>/dev/null)
    if [ -n "$config_apks" ]; then
        log_verbose "Merging additional config APKs..."
        echo "$config_apks" | while IFS= read -r config_apk; do
            if [ -n "$config_apk" ] && [ -f "$config_apk" ]; then
                unzip -o -q "$config_apk" -d "$merge_dir" 2>/dev/null || true
            fi
        done
    fi

    # Repackage as APK
    log_verbose "Repackaging merged APK..."
    local absolute_output="$WORK_DIR/$output_apk"
    cd "$merge_dir"
    if ! zip -r -q "$absolute_output" . 2>/dev/null; then
        print_error "Failed to repackage APK"
        cd "$WORK_DIR"
        rm -rf "$xapk_temp" "$merge_dir"
        return 1
    fi

    cd "$WORK_DIR"

    # Cleanup
    rm -rf "$xapk_temp" "$merge_dir"

    if [ ! -f "$output_apk" ]; then
        print_error "Failed to create merged APK"
        return 1
    fi

    local merged_size=$(du -h "$output_apk" 2>/dev/null | cut -f1)
    log_verbose "Merged APK size: $merged_size"

    return 0
}

get_apk() {
    print_header "Obtaining APK"

    # Option 1: User provided APK file
    if [ -n "$APK_FILE" ]; then
        # Convert to absolute path before changing directory
        if [[ "$APK_FILE" != /* ]]; then
            APK_FILE="$ORIGINAL_DIR/$APK_FILE"
        fi

        if [ ! -f "$APK_FILE" ]; then
            print_error "APK file not found: $APK_FILE"
            exit 1
        fi

        mkdir -p "$WORK_DIR"
        cd "$WORK_DIR"

        local apk_file="app.apk"

        # Check if it's an XAPK file
        if [[ "$APK_FILE" == *.xapk ]]; then
            print_info "Detected XAPK file: $APK_FILE"
            print_info "Extracting XAPK and merging split APKs..."

            if ! process_xapk "$APK_FILE" "$apk_file"; then
                print_error "Failed to process XAPK file"
                exit 1
            fi

            print_success "XAPK processed and merged"
            return 0
        fi

        print_info "Using provided APK file: $APK_FILE"
        cp "$APK_FILE" "$apk_file"
        print_success "APK file copied"
        return 0
    fi

    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"

    local apk_file="app.apk"

    # Extract package name from URL if provided
    if [ -n "$PLAY_STORE_URL" ]; then
        PACKAGE_NAME=$(extract_package_from_url "$PLAY_STORE_URL")
        print_success "Extracted package name: $PACKAGE_NAME"
    fi

    print_info "Package name: $PACKAGE_NAME"
    echo ""
    print_info "Trying multiple download methods..."
    echo ""

    # Try method 1: APKPure
    if download_apk_apkpure "$PACKAGE_NAME" "$apk_file"; then
        return 0
    fi

    # Try method 2: Connected Android device
    if download_apk_device "$PACKAGE_NAME" "$apk_file"; then
        return 0
    fi

    # All methods failed - provide user-friendly guidance
    print_error "Could not obtain APK automatically"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_warning "Don't worry! Here's how to get the APK manually:"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${BOLD}OPTION 1: Download from APKPure (Easiest)${NC}"
    echo ""
    echo "  1. Open this URL in your browser:"
    echo -e "     ${CYAN}https://apkpure.com/search?q=$PACKAGE_NAME${NC}"
    echo ""
    echo "  2. Click on the first result (the correct app)"
    echo "  3. Click the green 'Download APK' button"
    echo "  4. Save the file (it will be named like: app-name.apk)"
    echo ""
    echo "  5. Then run this exact command:"
    echo -e "     ${GREEN}$0 $(echo "$@" | sed 's/-u [^ ]*//' | sed 's/-p [^ ]*//')--file ~/Downloads/*.apk${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${BOLD}OPTION 2: Download from APKMirror (Alternative)${NC}"
    echo ""
    echo "  1. Open this URL in your browser:"
    echo -e "     ${CYAN}https://www.apkmirror.com/apk/$(echo $PACKAGE_NAME | cut -d'.' -f1-2)/${NC}"
    echo ""
    echo "  2. Find and click on the app"
    echo "  3. Click on the latest version"
    echo "  4. Scroll down and click 'Download APK'"
    echo "  5. Click 'Download' again to confirm"
    echo ""
    echo "  6. Then run:"
    echo -e "     ${GREEN}$0 $(echo "$@" | sed 's/-u [^ ]*//' | sed 's/-p [^ ]*//')--file ~/Downloads/*.apk${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${BOLD}OPTION 3: Copy from Android Device${NC}"
    echo ""

    # Check if ADB is available
    if command -v adb &> /dev/null; then
        echo "  ADB is installed! Run these commands:"
        echo ""
        echo -e "  ${GREEN}# 1. Connect your Android device via USB${NC}"
        echo -e "  ${GREEN}# 2. Enable 'USB Debugging' on your device${NC}"
        echo -e "  ${GREEN}# 3. Install the app from Play Store on your device${NC}"
        echo -e "  ${GREEN}# 4. Run this command:${NC}"
        echo ""
        echo -e "  ${CYAN}adb pull \$(adb shell pm path $PACKAGE_NAME 2>/dev/null | cut -d':' -f2 | tr -d '\\r') $WORK_DIR/app.apk && $0 $(echo "$@" | sed 's/-u [^ ]*//' | sed 's/-p [^ ]*//')--file $WORK_DIR/app.apk${NC}"
        echo ""
    else
        echo -e "  ${YELLOW}ADB not installed. Install with: brew install android-platform-tools${NC}"
        echo ""
        echo "  Then:"
        echo -e "  ${GREEN}# 1. Connect Android device via USB${NC}"
        echo -e "  ${GREEN}# 2. Enable USB debugging on device${NC}"
        echo -e "  ${GREEN}# 3. Install the app on device${NC}"
        echo -e "  ${GREEN}# 4. Run: adb pull \$(adb shell pm path $PACKAGE_NAME | cut -d':' -f2) app.apk${NC}"
        echo -e "  ${GREEN}# 5. Run: $0 $(echo "$@" | sed 's/-u [^ ]*//' | sed 's/-p [^ ]*//')--file app.apk${NC}"
    fi
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_info "After downloading, the script will automatically analyze the APK!"
    echo ""

    # Offer to open browser
    echo ""
    read -p "Would you like to open APKPure in your browser now? (y/n): " open_browser
    if [[ $open_browser =~ ^[Yy]$ ]]; then
        open "https://apkpure.com/search?q=$PACKAGE_NAME" 2>/dev/null || \
        xdg-open "https://apkpure.com/search?q=$PACKAGE_NAME" 2>/dev/null || \
        echo "Please open: https://apkpure.com/search?q=$PACKAGE_NAME"
        echo ""
        print_success "Browser opened! Download the APK and run the command shown above."
    fi

    echo ""
    exit 1
}

################################################################################
# Analysis Functions
################################################################################

extract_apk() {
    print_header "Extracting APK"

    cd "$WORK_DIR"

    if [ ! -f "app.apk" ]; then
        print_error "APK file not found"
        exit 1
    fi

    print_info "Decompiling APK with apktool..."

    if ! apktool d app.apk -o extracted -f &>/dev/null; then
        print_error "Failed to decompile APK"
        exit 1
    fi

    print_success "APK decompiled"

    # Also extract as zip for direct file access
    print_info "Extracting APK contents..."
    mkdir -p extracted-raw
    unzip -q app.apk -d extracted-raw 2>/dev/null || true

    print_success "APK extracted"

    APK_EXTRACTED_PATH="$WORK_DIR/extracted"
    APK_RAW_PATH="$WORK_DIR/extracted-raw"
}

get_app_info() {
    print_header "App Information"

    cd "$APK_EXTRACTED_PATH"

    local manifest="AndroidManifest.xml"

    if [ ! -f "$manifest" ]; then
        print_warning "AndroidManifest.xml not found"
        return
    fi

    # Extract app info from manifest (using sed for macOS compatibility)
    APP_INFO_PACKAGE=$(grep 'package=' "$manifest" | sed -n 's/.*package="\([^"]*\)".*/\1/p' | head -1 || echo "N/A")
    APP_INFO_VERSION_NAME=$(grep 'versionName=' "$manifest" | sed -n 's/.*versionName="\([^"]*\)".*/\1/p' | head -1 || echo "N/A")
    APP_INFO_VERSION_CODE=$(grep 'versionCode=' "$manifest" | sed -n 's/.*versionCode="\([^"]*\)".*/\1/p' | head -1 || echo "N/A")

    # Try to get app name from strings
    local strings_file="res/values/strings.xml"
    if [ -f "$strings_file" ]; then
        APP_INFO_NAME=$(grep 'name="app_name"' "$strings_file" | sed -n 's/.*>\(.*\)<.*/\1/p' | head -1 || echo "$APP_INFO_PACKAGE")
    else
        APP_INFO_NAME="$APP_INFO_PACKAGE"
    fi

    echo "Package:      $APP_INFO_PACKAGE"
    echo "Name:         $APP_INFO_NAME"
    echo "Version:      $APP_INFO_VERSION_NAME"
    echo "Version Code: $APP_INFO_VERSION_CODE"

    local apk_size=$(du -sh "$WORK_DIR/app.apk" 2>/dev/null | cut -f1)
    echo "APK Size:     $apk_size"
}

load_competitors() {
    if [ ! -f "$COMPETITORS_FILE" ]; then
        log_verbose "Competitors file not found: $COMPETITORS_FILE"
        return
    fi

    log_verbose "Loading competitors from: $COMPETITORS_FILE"

    # Read competitors file, extract names, and create search patterns
    while IFS= read -r line; do
        # Skip empty lines and comments
        if [ -z "$line" ] || [[ "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi

        # Extract just the company/product name, removing bracketed text
        local competitor=$(echo "$line" | sed 's/\[.*\]//' | xargs)

        if [ -n "$competitor" ]; then
            COMPETITOR_NAMES+=("$competitor")
        fi
    done < "$COMPETITORS_FILE"

    log_verbose "Loaded ${#COMPETITOR_NAMES[@]} competitors"
}

check_for_competitors() {
    COMPETITOR_PRODUCTS=()

    if [ ${#COMPETITOR_NAMES[@]} -eq 0 ]; then
        return
    fi

    log_verbose "Checking for competitor products..."

    # Check all libraries
    for details in "${ALL_LIBRARY_DETAILS[@]}"; do
        IFS='|' read -r lib_name lib_path lib_size description vendor version <<< "$details"

        # Check if library name or path matches any competitor
        for competitor in "${COMPETITOR_NAMES[@]}"; do
            # Create case-insensitive pattern
            local pattern=$(echo "$competitor" | sed 's/ /.*/g')

            if echo "$lib_name" | grep -iq "$pattern" || echo "$lib_path" | grep -iq "$pattern"; then
                local match_info="$lib_name|$lib_path|$lib_size|$competitor"
                COMPETITOR_PRODUCTS+=("$match_info")
                log_verbose "Found competitor match: $competitor in $lib_name"
                break
            fi
        done
    done

    if [ ${#COMPETITOR_PRODUCTS[@]} -gt 0 ]; then
        print_warning "Detected ${#COMPETITOR_PRODUCTS[@]} competitor product(s)"
    fi
}

list_all_libraries() {
    print_header "Library & SDK Analysis"

    ALL_LIBRARIES=()
    ALL_LIBRARY_DETAILS=()
    COMPETITOR_NAMES=()

    # Load competitors list and library info database
    load_competitors
    load_library_info

    # Extract all metadata
    extract_library_versions
    extract_play_services_versions
    extract_androidx_libraries
    extract_permissions
    extract_build_info
    extract_kotlin_info
    extract_assets_summary

    # List all native libraries
    if [ -d "$APK_RAW_PATH/lib" ]; then
        echo -e "${BOLD}📦 Native Libraries:${NC}\n"

        local lib_count=0
        while IFS= read -r lib_file; do
            if [ -z "$lib_file" ]; then
                continue
            fi

            lib_count=$((lib_count + 1))
            local lib_name=$(basename "$lib_file")
            local lib_arch=$(basename $(dirname "$lib_file"))
            local lib_size=$(du -h "$lib_file" 2>/dev/null | cut -f1)

            ALL_LIBRARIES+=("$lib_name")

            # Get library description, vendor, and version
            local description=$(get_library_description "$lib_name")
            local vendor=$(get_library_vendor "$lib_name")
            local version=$(get_library_version "$lib_name")

            echo -e "${CYAN}${BOLD}$lib_count. $lib_name${NC}"

            # Show description if available
            if [ -n "$description" ]; then
                echo "   Description:  $description"
            fi

            # Show vendor if available
            if [ -n "$vendor" ]; then
                echo "   Vendor:       $vendor"
            fi

            # Show version if available
            if [ -n "$version" ]; then
                echo "   Version:      $version"
            fi

            echo "   Architecture: $lib_arch"
            echo "   Size:         $lib_size"

            local lib_details="$lib_name|$lib_file|$lib_size|$description|$vendor|$version"
            ALL_LIBRARY_DETAILS+=("$lib_details")
            echo ""
        done < <(find "$APK_RAW_PATH/lib" -type f -name "*.so" 2>/dev/null)

        if [ $lib_count -eq 0 ]; then
            echo "   (No native libraries found)"
            echo ""
        else
            print_success "Found $lib_count native library/libraries"
        fi
    else
        echo -e "${BOLD}📦 Native Libraries:${NC}\n"
        echo "   (No lib directory found)"
        echo ""
    fi

    # Check for competitors
    check_for_competitors

    # Display competitor products if found
    if [ ${#COMPETITOR_PRODUCTS[@]} -gt 0 ]; then
        echo -e "\n${BOLD}${RED}⚠️  POTENTIAL COMPETITOR PRODUCTS DETECTED:${NC}\n"

        local idx=1
        for match_info in "${COMPETITOR_PRODUCTS[@]}"; do
            IFS='|' read -r lib_name lib_path lib_size competitor <<< "$match_info"
            echo -e "${RED}${BOLD}$idx. $lib_name${NC}"
            echo "   Competitor:  $competitor"
            echo "   Path:        $lib_path"
            echo "   Size:        $lib_size"
            echo ""
            idx=$((idx + 1))
        done
    fi

    # List major Java packages
    echo -e "\n${BOLD}📚 Java Packages (Top Level):${NC}\n"

    if [ -d "$APK_EXTRACTED_PATH/smali" ]; then
        # Find top-level packages
        local packages=$(find "$APK_EXTRACTED_PATH/smali" -maxdepth 2 -type d | grep -v "^$APK_EXTRACTED_PATH/smali$" | sort | head -20)

        if [ -n "$packages" ]; then
            echo "$packages" | while IFS= read -r pkg; do
                local pkg_name=$(echo "$pkg" | sed "s|$APK_EXTRACTED_PATH/smali/||" | tr '/' '.')
                local file_count=$(find "$pkg" -type f -name "*.smali" 2>/dev/null | wc -l | tr -d ' ')
                echo "   • $pkg_name ($file_count classes)"
            done
            echo ""
        else
            echo "   (No packages found)"
            echo ""
        fi
    else
        echo "   (No smali directory found)"
        echo ""
    fi

    # Summary
    if [ ${#COMPETITOR_PRODUCTS[@]} -gt 0 ]; then
        echo -e "${RED}${BOLD}⚠️  WARNING: Found ${#COMPETITOR_PRODUCTS[@]} competitor product(s)${NC}"
    fi
    echo -e "${GREEN}${BOLD}✅ Analysis complete${NC}"
}

detect_sdks() {
    # If listing all libraries, use the new function
    if [ "$LIST_ALL_LIBRARIES" = true ]; then
        list_all_libraries
        return
    fi

    # Otherwise, search for specific SDKs
    print_header "SDK Detection"

    DETECTED_SDKS=()

    for sdk_name in "${SDK_NAMES[@]}"; do
        echo -e "\n${BOLD}Searching for: ${sdk_name}${NC}"

        local found=false
        local details=""

        # Method 1: Check lib/ directories for native libraries
        log_verbose "Checking native libraries..."
        if [ -d "$APK_RAW_PATH/lib" ]; then
            local native_libs=$(find "$APK_RAW_PATH/lib" -type f -iname "*${sdk_name}*" 2>/dev/null || true)

            if [ -n "$native_libs" ]; then
                found=true
                print_found "Native libraries detected"

                echo "$native_libs" | while IFS= read -r lib; do
                    local lib_name=$(basename "$lib")
                    local lib_size=$(du -h "$lib" 2>/dev/null | cut -f1)
                    echo "  📦 $lib_name ($lib_size)"
                done

                local lib_count=$(echo "$native_libs" | wc -l | tr -d ' ')
                details="$details\n  - Native libraries: $lib_count file(s)"
            fi
        fi

        # Method 2: Check for Java classes/packages
        log_verbose "Checking Java classes..."
        local java_classes=$(find "$APK_EXTRACTED_PATH" -type f -path "*smali*" -iname "*${sdk_name}*" 2>/dev/null | head -20 || true)

        if [ -n "$java_classes" ]; then
            local class_count=$(echo "$java_classes" | wc -l | tr -d ' ')
            if [ "$class_count" -gt 0 ]; then
                if [ "$found" = false ]; then
                    found=true
                fi
                print_found "Java classes detected ($class_count files)"

                if [ "$VERBOSE" = true ]; then
                    echo "$java_classes" | head -5 | while IFS= read -r class; do
                        local class_name=$(basename "$class")
                        echo "  📄 $class_name"
                    done
                fi

                details="$details\n  - Java classes: $class_count file(s)"
            fi
        fi

        # Method 3: Check for SDK in assets or resources
        log_verbose "Checking assets and resources..."
        local assets=$(find "$APK_EXTRACTED_PATH" -type f \( -path "*/assets/*" -o -path "*/res/*" \) -iname "*${sdk_name}*" 2>/dev/null | head -10 || true)

        if [ -n "$assets" ]; then
            local asset_count=$(echo "$assets" | wc -l | tr -d ' ')
            if [ "$asset_count" -gt 0 ]; then
                if [ "$found" = false ]; then
                    found=true
                fi
                print_found "Assets/resources detected ($asset_count files)"

                details="$details\n  - Assets/resources: $asset_count file(s)"
            fi
        fi

        # Method 4: Search in manifest and XML files
        log_verbose "Checking manifest and XML files..."
        if grep -r -i "$sdk_name" "$APK_EXTRACTED_PATH/AndroidManifest.xml" &>/dev/null; then
            if [ "$found" = false ]; then
                found=true
            fi
            print_found "References in AndroidManifest.xml"
            details="$details\n  - Mentioned in AndroidManifest.xml"
        fi

        # Summary for this SDK
        if [ "$found" = true ]; then
            DETECTED_SDKS+=("$sdk_name")
            echo -e "\n${GREEN}${BOLD}✅ RESULT: $sdk_name SDK IS PRESENT${NC}"
        else
            echo -e "\n${RED}${BOLD}❌ RESULT: $sdk_name SDK NOT DETECTED${NC}"
        fi

        # Store details for report
        eval "SDK_DETAILS_${sdk_name}='$details'"
    done
}

################################################################################
# Report Generation
################################################################################

generate_report() {
    print_header "Generating Report"

    # Create filename with package name
    local report_filename="$OUTPUT_REPORT"

    if [ "$OUTPUT_REPORT" = "sdk-detection-report.txt" ]; then
        local identifier="${APP_INFO_PACKAGE}"
        if [ -z "$identifier" ] || [ "$identifier" = "N/A" ]; then
            identifier="${APP_INFO_NAME}"
        fi

        identifier=$(echo "$identifier" | tr '.' '-' | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')

        local timestamp=$(date +%Y%m%d-%H%M%S)

        if [ "$LIST_ALL_LIBRARIES" = true ]; then
            report_filename="library-analysis-android-${identifier}-${timestamp}.txt"
        else
            report_filename="sdk-detection-android-${identifier}-${timestamp}.txt"
        fi
    fi

    local report_file="$ORIGINAL_DIR/$report_filename"
    FINAL_REPORT_PATH="$report_file"

    # Generate different reports based on mode
    if [ "$LIST_ALL_LIBRARIES" = true ]; then
        generate_all_libraries_report "$report_file"
    else
        generate_sdk_detection_report "$report_file"
    fi

    print_success "Report saved to: $report_file"

    echo ""
    cat "$report_file"
}

generate_all_libraries_report() {
    local report_file="$1"

    cat > "$report_file" << EOF
--------------------------------------------------------------------------------
ANDROID APP LIBRARY & SDK ANALYSIS REPORT
--------------------------------------------------------------------------------

Generated: $(date "+%Y-%m-%d %H:%M:%S")
Analysis Tool: Android SDK Detection Script v1.0

--------------------------------------------------------------------------------
APP INFORMATION
--------------------------------------------------------------------------------

Package:        $APP_INFO_PACKAGE
Name:           $APP_INFO_NAME
Version:        $APP_INFO_VERSION_NAME
Version Code:   $APP_INFO_VERSION_CODE
APK Size:       $(du -sh "$WORK_DIR/app.apk" 2>/dev/null | cut -f1)

EOF

    # Add competitor detection section if competitors found
    if [ ${#COMPETITOR_PRODUCTS[@]} -gt 0 ]; then
        cat >> "$report_file" << EOF
--------------------------------------------------------------------------------
⚠️  POTENTIAL COMPETITOR PRODUCTS DETECTED
--------------------------------------------------------------------------------

WARNING: This app contains ${#COMPETITOR_PRODUCTS[@]} potential competitor product(s):

EOF
        local idx=1
        for match_info in "${COMPETITOR_PRODUCTS[@]}"; do
            IFS='|' read -r lib_name lib_path lib_size competitor <<< "$match_info"
            cat >> "$report_file" << EOF
$idx. $lib_name
   Competitor:  $competitor
   Path:        $lib_path
   Size:        $lib_size

EOF
            idx=$((idx + 1))
        done

        cat >> "$report_file" << EOF

EOF
    fi

    cat >> "$report_file" << EOF
--------------------------------------------------------------------------------
NATIVE LIBRARIES
--------------------------------------------------------------------------------

EOF

    if [ ${#ALL_LIBRARIES[@]} -eq 0 ]; then
        cat >> "$report_file" << EOF
No native libraries found in the APK.

EOF
    else
        cat >> "$report_file" << EOF
Found ${#ALL_LIBRARIES[@]} native library/libraries:

EOF
        local idx=1
        for details in "${ALL_LIBRARY_DETAILS[@]}"; do
            IFS='|' read -r lib_name lib_path lib_size description vendor version <<< "$details"
            local lib_arch=$(basename $(dirname "$lib_path"))
            cat >> "$report_file" << EOF
$idx. $lib_name
   Architecture: $lib_arch
   Size:         $lib_size
EOF
            if [ -n "$description" ]; then
                echo "   Description:  $description" >> "$report_file"
            fi
            if [ -n "$vendor" ]; then
                echo "   Vendor:       $vendor" >> "$report_file"
            fi
            if [ -n "$version" ]; then
                echo "   Version:      $version" >> "$report_file"
            fi
            echo "" >> "$report_file"
            idx=$((idx + 1))
        done
    fi

    cat >> "$report_file" << EOF
--------------------------------------------------------------------------------
JAVA PACKAGES
--------------------------------------------------------------------------------

EOF

    if [ -d "$APK_EXTRACTED_PATH/smali" ]; then
        local packages=$(find "$APK_EXTRACTED_PATH/smali" -maxdepth 2 -type d | grep -v "^$APK_EXTRACTED_PATH/smali$" | sort | head -20)
        if [ -n "$packages" ]; then
            echo "$packages" | while IFS= read -r pkg; do
                local pkg_name=$(echo "$pkg" | sed "s|$APK_EXTRACTED_PATH/smali/||" | tr '/' '.')
                local file_count=$(find "$pkg" -type f -name "*.smali" 2>/dev/null | wc -l | tr -d ' ')
                echo "  • $pkg_name ($file_count classes)" >> "$report_file"
            done
        else
            echo "  (No packages found)" >> "$report_file"
        fi
    else
        echo "  (No smali directory found)" >> "$report_file"
    fi

    cat >> "$report_file" << EOF

EOF

    # Add Google Play Services section
    if [ ${#PLAY_SERVICES_VERSIONS[@]} -gt 0 ]; then
        cat >> "$report_file" << EOF
--------------------------------------------------------------------------------
GOOGLE PLAY SERVICES & FIREBASE
--------------------------------------------------------------------------------

Found ${#PLAY_SERVICES_VERSIONS[@]} Google Play Services/Firebase libraries:

EOF
        for entry in "${PLAY_SERVICES_VERSIONS[@]}"; do
            IFS='|' read -r client version <<< "$entry"
            echo "  • $client ($version)" >> "$report_file"
        done | sort >> "$report_file"
        echo "" >> "$report_file"
    fi

    # Add AndroidX libraries section
    if [ ${#ANDROIDX_LIBRARIES[@]} -gt 0 ]; then
        cat >> "$report_file" << EOF
--------------------------------------------------------------------------------
ANDROIDX LIBRARIES
--------------------------------------------------------------------------------

Found ${#ANDROIDX_LIBRARIES[@]} AndroidX/Jetpack libraries:

EOF
        for lib_entry in "${ANDROIDX_LIBRARIES[@]}"; do
            IFS='|' read -r lib_name version <<< "$lib_entry"
            echo "  • $lib_name ($version)" >> "$report_file"
        done | sort >> "$report_file"
        echo "" >> "$report_file"
    fi

    # Add Kotlin info section
    if [ ${#KOTLIN_INFO[@]} -gt 0 ]; then
        cat >> "$report_file" << EOF
--------------------------------------------------------------------------------
KOTLIN LIBRARIES
--------------------------------------------------------------------------------

EOF
        for entry in "${KOTLIN_INFO[@]}"; do
            IFS='|' read -r lib version <<< "$entry"
            if [ "$lib" != "metadata_found" ]; then
                echo "  • $lib ($version)" >> "$report_file"
            fi
        done | sort >> "$report_file"
        echo "" >> "$report_file"
    fi

    # Add permissions section
    if [ ${#APP_PERMISSIONS[@]} -gt 0 ]; then
        cat >> "$report_file" << EOF
--------------------------------------------------------------------------------
PERMISSIONS
--------------------------------------------------------------------------------

This app requests ${#APP_PERMISSIONS[@]} permissions:

EOF
        for perm in "${APP_PERMISSIONS[@]}"; do
            echo "  • $perm" >> "$report_file"
        done | sort >> "$report_file"
        echo "" >> "$report_file"
    fi

    # Add features section
    if [ ${#APP_FEATURES[@]} -gt 0 ]; then
        cat >> "$report_file" << EOF
--------------------------------------------------------------------------------
HARDWARE FEATURES
--------------------------------------------------------------------------------

This app declares ${#APP_FEATURES[@]} hardware features:

EOF
        for feat_entry in "${APP_FEATURES[@]}"; do
            IFS='|' read -r feat required <<< "$feat_entry"
            echo "  • $feat [$required]" >> "$report_file"
        done | sort >> "$report_file"
        echo "" >> "$report_file"
    fi

    # Add build info section
    if [ ${#BUILD_INFO[@]} -gt 0 ]; then
        cat >> "$report_file" << EOF
--------------------------------------------------------------------------------
BUILD INFORMATION
--------------------------------------------------------------------------------

EOF
        for entry in "${BUILD_INFO[@]}"; do
            IFS='|' read -r key value <<< "$entry"
            echo "  $key: $value" >> "$report_file"
        done | sort >> "$report_file"
        echo "" >> "$report_file"
    fi

    # Add assets summary section
    if [ ${#ASSETS_INFO[@]} -gt 0 ]; then
        # Parse ASSETS_INFO array to extract values
        local asset_count asset_size res_count res_size languages
        for entry in "${ASSETS_INFO[@]}"; do
            IFS='|' read -r key value <<< "$entry"
            case "$key" in
                asset_count) asset_count="$value" ;;
                asset_size) asset_size="$value" ;;
                res_count) res_count="$value" ;;
                res_size) res_size="$value" ;;
                languages) languages="$value" ;;
            esac
        done

        cat >> "$report_file" << EOF
--------------------------------------------------------------------------------
ASSETS & RESOURCES SUMMARY
--------------------------------------------------------------------------------

Assets:    $asset_count files ($asset_size)
Resources: $res_count files ($res_size)
EOF
        if [ -n "$languages" ]; then
            echo "Languages: $languages" >> "$report_file"
        fi
        echo "" >> "$report_file"
    fi

    cat >> "$report_file" << EOF
--------------------------------------------------------------------------------
TECHNICAL DETAILS
--------------------------------------------------------------------------------

Analysis Directory: $WORK_DIR
APK Path:           $WORK_DIR/app.apk
Extracted Path:     $APK_EXTRACTED_PATH
Library Database:   $SCRIPT_DIR/library-info.txt
Competitors File:   $COMPETITORS_FILE

--------------------------------------------------------------------------------
END OF REPORT
--------------------------------------------------------------------------------
EOF
}

generate_sdk_detection_report() {
    local report_file="$1"

    cat > "$report_file" << EOF
--------------------------------------------------------------------------------
ANDROID APP SDK DETECTION REPORT
--------------------------------------------------------------------------------

Generated: $(date "+%Y-%m-%d %H:%M:%S")
Analysis Tool: Android SDK Detection Script v1.0

--------------------------------------------------------------------------------
APP INFORMATION
--------------------------------------------------------------------------------

Package:        $APP_INFO_PACKAGE
Name:           $APP_INFO_NAME
Version:        $APP_INFO_VERSION_NAME
Version Code:   $APP_INFO_VERSION_CODE
APK Size:       $(du -sh "$WORK_DIR/app.apk" 2>/dev/null | cut -f1)

--------------------------------------------------------------------------------
SDK DETECTION RESULTS
--------------------------------------------------------------------------------

Searched for SDKs: ${SDK_NAMES[*]}

EOF

    if [ ${#DETECTED_SDKS[@]} -eq 0 ]; then
        cat >> "$report_file" << EOF
RESULT: ❌ NONE OF THE SPECIFIED SDKs WERE DETECTED

The app does not appear to contain any of the following SDKs:
EOF
        for sdk in "${SDK_NAMES[@]}"; do
            echo "  - $sdk" >> "$report_file"
        done
    else
        cat >> "$report_file" << EOF
RESULT: ✅ THE FOLLOWING SDKs WERE DETECTED:

EOF
        for sdk in "${DETECTED_SDKS[@]}"; do
            echo "✅ $sdk" >> "$report_file"

            local details_var="SDK_DETAILS_${sdk}"
            local details="${!details_var}"
            if [ -n "$details" ]; then
                echo -e "$details" >> "$report_file"
            fi
            echo "" >> "$report_file"
        done

        cat >> "$report_file" << EOF

The following SDKs were NOT detected:
EOF
        for sdk in "${SDK_NAMES[@]}"; do
            if [[ ! " ${DETECTED_SDKS[@]} " =~ " ${sdk} " ]]; then
                echo "  - $sdk" >> "$report_file"
            fi
        done
    fi

    cat >> "$report_file" << EOF

--------------------------------------------------------------------------------
DETECTION METHODS USED
--------------------------------------------------------------------------------

1. Native Library Inspection
   - Searched lib/ directories for .so files
   - Checked all CPU architectures (arm, arm64, x86, etc.)

2. Java Class Analysis
   - Searched decompiled smali code for SDK classes
   - Checked package names and class hierarchies

3. Asset and Resource Search
   - Searched assets/ directory for SDK files
   - Checked res/ directory for SDK resources

4. Manifest Analysis
   - Checked AndroidManifest.xml for SDK references
   - Verified permissions and SDK declarations

--------------------------------------------------------------------------------
CONCLUSION
--------------------------------------------------------------------------------

EOF

    if [ ${#DETECTED_SDKS[@]} -eq 0 ]; then
        cat >> "$report_file" << EOF
The analyzed Android app does NOT contain any of the specified SDKs.

If you expected to find these SDKs, consider:
- The SDK may be obfuscated or renamed (ProGuard/R8)
- The SDK may have been removed in this version
- The search terms may need adjustment
- Try analyzing with ProGuard mapping file if available

EOF
    else
        cat >> "$report_file" << EOF
The analyzed Android app CONTAINS the following SDK(s): ${DETECTED_SDKS[*]}

This indicates active integration of the SDK in the current version.

For license compliance:
- Verify if this usage is authorized
- Check if the SDK version matches license terms
- Document the findings appropriately
- Contact the app developer if unauthorized use is suspected

EOF
    fi

    cat >> "$report_file" << EOF
--------------------------------------------------------------------------------
TECHNICAL DETAILS
--------------------------------------------------------------------------------

Analysis Directory: $WORK_DIR
Package Name:       $APP_INFO_PACKAGE
APK Path:           $WORK_DIR/app.apk

--------------------------------------------------------------------------------
END OF REPORT
--------------------------------------------------------------------------------
EOF
}

################################################################################
# Cleanup
################################################################################

cleanup() {
    cd "$ORIGINAL_DIR"

    if [ "$CLEANUP" = true ]; then
        print_header "Cleanup"
        print_info "Removing temporary files from: $WORK_DIR"
        rm -rf "$WORK_DIR"
        print_success "Cleanup complete"
        print_info "Report saved to: $FINAL_REPORT_PATH"
    else
        print_info "Analysis files kept at: $WORK_DIR"
        print_info "Report saved to: $FINAL_REPORT_PATH"
    fi
}

################################################################################
# Main Script
################################################################################

main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--sdk)
                SDK_NAMES+=("$2")
                shift 2
                ;;
            -a|--list-all)
                LIST_ALL_LIBRARIES=true
                shift
                ;;
            -u|--url)
                PLAY_STORE_URL="$2"
                shift 2
                ;;
            -p|--package)
                PACKAGE_NAME="$2"
                shift 2
                ;;
            -f|--file)
                APK_FILE="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_REPORT="$2"
                shift 2
                ;;
            -w|--work-dir)
                WORK_DIR="$2"
                shift 2
                ;;
            --no-cleanup)
                CLEANUP=false
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo ""
                show_usage
                exit 1
                ;;
        esac
    done

    # Print banner
    echo -e "${BOLD}${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║      Android App SDK Detection Script v1.0                     ║"
    echo "║      License Compliance & Security Analysis                    ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"

    # Validate inputs
    validate_inputs

    # Check requirements
    check_requirements

    # Get APK
    get_apk

    # Extract APK
    extract_apk

    # Get app info
    get_app_info

    # Detect SDKs
    detect_sdks

    # Generate report
    generate_report

    # Cleanup
    cleanup

    # Final summary
    print_header "Analysis Complete"

    if [ "$LIST_ALL_LIBRARIES" = true ]; then
        if [ ${#ALL_LIBRARIES[@]} -eq 0 ]; then
            echo -e "${YELLOW}${BOLD}No native libraries found${NC}"
        else
            echo -e "${GREEN}${BOLD}Found ${#ALL_LIBRARIES[@]} native library/libraries${NC}"
        fi
        if [ ${#COMPETITOR_PRODUCTS[@]} -gt 0 ]; then
            echo -e "${RED}${BOLD}⚠️  WARNING: Found ${#COMPETITOR_PRODUCTS[@]} competitor product(s)${NC}"
        fi
    else
        if [ ${#DETECTED_SDKS[@]} -eq 0 ]; then
            echo -e "${RED}${BOLD}No SDKs detected${NC}"
        else
            echo -e "${GREEN}${BOLD}Detected SDKs: ${DETECTED_SDKS[*]}${NC}"
        fi
    fi

    echo ""
    echo -e "${BLUE}${BOLD}📄 Full report: $FINAL_REPORT_PATH${NC}"
    exit 0
}

# Run main function
main "$@"
