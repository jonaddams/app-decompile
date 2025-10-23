#!/bin/bash

################################################################################
# iOS App SDK Detection Script
#
# Description: Automates the process of downloading and analyzing iOS apps
#              to detect the presence of specific SDKs or frameworks.
#
# Usage: ./detect-sdk.sh [OPTIONS]
#
# Author: Created for SDK license compliance verification
# Version: 1.0
################################################################################

set -e  # Exit on error

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
WORK_DIR="${PWD}/sdk-analysis-$(date +%Y%m%d-%H%M%S)"
SDK_NAMES=()
APP_STORE_URL=""
BUNDLE_ID=""
APP_ID=""
SEARCH_TERM=""
OUTPUT_REPORT="sdk-detection-report.txt"
CLEANUP=true
VERBOSE=false
LIST_ALL_FRAMEWORKS=false
COMPETITORS_FILE="$ORIGINAL_DIR/competitors.txt"
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
${BOLD}iOS App SDK Detection Script${NC}

${BOLD}USAGE:${NC}
    $0 [OPTIONS]

${BOLD}OPTIONS:${NC}
    -s, --sdk <name>          SDK name to search for (can be used multiple times)
                              Example: -s pspdfkit -s nutrient
                              Note: If not specified, all frameworks will be listed

    -a, --list-all            List all frameworks and libraries (default if no -s specified)

    -u, --url <url>           App Store URL
                              Example: https://apps.apple.com/us/app/app-name/id1234567890

    -b, --bundle <id>         Bundle identifier
                              Example: com.example.app

    -i, --app-id <id>         App Store ID (numeric)
                              Example: 1234567890

    -q, --search <term>       Search for app by name
                              Example: "Instagram"

    -o, --output <file>       Output report file (default: auto-generated with app name)

    -w, --work-dir <dir>      Working directory for analysis (default: auto-generated)

    --no-cleanup              Don't delete temporary files after analysis

    -v, --verbose             Enable verbose output

    -h, --help                Show this help message

${BOLD}EXAMPLES:${NC}
    # List all frameworks in an app from URL
    $0 -u "https://apps.apple.com/us/app/example/id123456"

    # List all frameworks using bundle ID
    $0 -b com.example.app

    # Search for specific SDKs
    $0 -s pspdfkit -s nutrient -b com.example.app

    # List all frameworks with verbose output and keep files
    $0 -a -b com.example.app -v --no-cleanup

${BOLD}FIRST-TIME SETUP:${NC}
    The script will automatically install and configure everything you need:
    - Homebrew (if not installed)
    - ipatool (if not installed)
    - Apple ID authentication (interactive prompt)

    Just run the script and it will guide you through setup!

${BOLD}REQUIREMENTS:${NC}
    - macOS (macOS 10.15 or later recommended)
    - Internet connection
    - Apple ID account (for downloading apps)

${BOLD}IMPORTANT LIMITATIONS:${NC}
    ipatool can ONLY download apps that meet BOTH conditions:
    1. Available in your Apple ID's region (US, UK, etc.)
    2. Previously purchased/downloaded by your Apple ID

    Common errors:
    - "item is temporarily unavailable" = App not in your region or not purchased
    - "password token is expired" = Run: ipatool auth login --email your@email.com

    To test: Use apps you've already downloaded from your region's App Store.

EOF
}

################################################################################
# Validation Functions
################################################################################

install_homebrew() {
    print_info "Homebrew not found. Installing Homebrew..."
    echo ""

    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    if [[ $(uname -m) == 'arm64' ]]; then
        # Apple Silicon
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        # Intel
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    if command -v brew &> /dev/null; then
        print_success "Homebrew installed successfully"
    else
        print_error "Homebrew installation failed"
        echo ""
        echo "Please install Homebrew manually:"
        echo "Visit: https://brew.sh"
        exit 1
    fi
}

install_ipatool() {
    print_info "ipatool not found. Installing ipatool via Homebrew..."

    if ! brew install ipatool; then
        print_error "Failed to install ipatool"
        echo ""
        echo "Please try manually:"
        echo "  $ brew install ipatool"
        exit 1
    fi

    print_success "ipatool installed successfully"
}

authenticate_ipatool() {
    print_warning "ipatool is not authenticated"
    echo ""
    echo "You need to authenticate with your Apple ID to download apps."
    echo ""
    echo "IMPORTANT: ipatool can ONLY download apps that are:"
    echo "  1. Available in your Apple ID's region"
    echo "  2. Previously purchased/downloaded by your Apple ID"
    echo ""
    read -p "Enter your Apple ID email: " apple_id

    if [ -z "$apple_id" ]; then
        print_error "Apple ID email is required"
        exit 1
    fi

    print_info "Authenticating with Apple ID: $apple_id"
    echo ""

    if ! ipatool auth login --email "$apple_id"; then
        print_error "Authentication failed"
        echo ""
        echo "Please try again or authenticate manually:"
        echo "  $ ipatool auth login --email your@email.com"
        exit 1
    fi

    print_success "Successfully authenticated with Apple ID"
    echo ""
    print_info "If downloads fail with 'temporarily unavailable':"
    echo "  - The app may not be in your Apple ID's region"
    echo "  - You may not have previously downloaded the app"
    echo "  - Try with apps you've already installed on your devices"
}

check_requirements() {
    print_header "Checking Requirements"

    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        install_homebrew
    else
        log_verbose "Homebrew: found"
        print_success "Homebrew is installed"
    fi

    # Check for ipatool
    if ! command -v ipatool &> /dev/null; then
        install_ipatool
    else
        log_verbose "ipatool: found"
        print_success "ipatool is installed"
    fi

    # Check for other required commands (built into macOS)
    local missing_tools=()
    for cmd in unzip strings otool plutil grep find; do
        if ! command -v $cmd &> /dev/null; then
            missing_tools+=("$cmd")
        else
            log_verbose "$cmd: found"
        fi
    done

    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        echo ""
        echo "These tools should be part of macOS Command Line Tools."
        echo "Install them with:"
        echo "  $ xcode-select --install"
        exit 1
    fi

    print_success "All required tools found"

    # Check ipatool authentication
    log_verbose "Checking ipatool authentication..."
    if ! ipatool auth info &> /dev/null; then
        authenticate_ipatool
    else
        local auth_email=$(ipatool auth info 2>/dev/null | grep -o 'email=[^ ]*' | cut -d= -f2)
        print_success "ipatool is authenticated (${auth_email})"

        # Provide helpful reminder about limitations
        log_verbose "Note: Can only download apps from your Apple ID's region that you've previously downloaded"
    fi
}

validate_inputs() {
    # If no SDK names provided, enable list all mode
    if [ ${#SDK_NAMES[@]} -eq 0 ]; then
        LIST_ALL_FRAMEWORKS=true
        log_verbose "No specific SDKs specified - will list all frameworks"
    fi

    # Check that at least one app identifier is provided
    if [ -z "$APP_STORE_URL" ] && [ -z "$BUNDLE_ID" ] && [ -z "$APP_ID" ] && [ -z "$SEARCH_TERM" ]; then
        print_error "Must provide one of: --url, --bundle, --app-id, or --search"
        echo ""
        show_usage
        exit 1
    fi
}

################################################################################
# App Discovery Functions
################################################################################

extract_id_from_url() {
    local url="$1"
    # Extract numeric ID from URL like https://apps.apple.com/us/app/name/id1234567890
    # This automatically strips query parameters (?foo=bar) and fragments (#section)
    # Examples that work:
    #   - https://apps.apple.com/us/app/name/id1234567890
    #   - https://apps.apple.com/us/app/name/id1234567890?l=es-MX
    #   - https://apps.apple.com/us/app/name/id1234567890?mt=8&uo=4
    #   - https://apps.apple.com/gb/app/name/id1234567890#screenshots
    local app_id=$(echo "$url" | grep -oE 'id[0-9]+' | grep -oE '[0-9]+')

    if [ -z "$app_id" ]; then
        print_error "Could not extract app ID from URL: $url"
        echo ""
        echo "Please provide a valid App Store URL containing an app ID."
        echo "Example: https://apps.apple.com/us/app/app-name/id1234567890"
        exit 1
    fi

    echo "$app_id"
}

search_app() {
    print_header "Searching for App"

    print_info "Searching for: $SEARCH_TERM"

    local search_results=$(ipatool search "$SEARCH_TERM" --limit 10 2>&1)

    if [ $? -ne 0 ]; then
        print_error "Search failed: $search_results"
        exit 1
    fi

    echo "$search_results"
    echo ""

    # Parse results (ipatool outputs JSON)
    local count=$(echo "$search_results" | grep -o '"id"' | wc -l | tr -d ' ')

    if [ "$count" -eq 0 ]; then
        print_error "No apps found matching '$SEARCH_TERM'"
        exit 1
    fi

    print_info "Found $count app(s)"

    if [ "$count" -eq 1 ]; then
        # Auto-select if only one result
        BUNDLE_ID=$(echo "$search_results" | grep -o '"bundleID":"[^"]*"' | head -1 | cut -d'"' -f4)
        print_success "Auto-selected: $BUNDLE_ID"
    else
        # Ask user to select
        echo ""
        print_info "Multiple apps found. Please select one:"
        echo "$search_results" | grep -E '"(name|bundleID|id)"' | head -30
        echo ""
        read -p "Enter bundle ID or app ID to analyze: " user_selection

        if [[ $user_selection =~ ^[0-9]+$ ]]; then
            APP_ID="$user_selection"
        else
            BUNDLE_ID="$user_selection"
        fi
    fi
}

get_app_identifier() {
    if [ -n "$APP_STORE_URL" ]; then
        print_info "Extracting app ID from URL..."
        APP_ID=$(extract_id_from_url "$APP_STORE_URL")
        if [ -z "$APP_ID" ]; then
            print_error "Could not extract app ID from URL: $APP_STORE_URL"
            exit 1
        fi
        print_success "Extracted app ID: $APP_ID"
    elif [ -n "$SEARCH_TERM" ]; then
        search_app
    fi
}

################################################################################
# Download and Extract Functions
################################################################################

download_app() {
    print_header "Downloading App"

    local ipa_file="$WORK_DIR/app.ipa"

    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"

    print_info "Working directory: $WORK_DIR"

    local download_cmd="ipatool download --purchase -o app.ipa"

    if [ -n "$BUNDLE_ID" ]; then
        print_info "Downloading app with bundle ID: $BUNDLE_ID"
        download_cmd="$download_cmd -b $BUNDLE_ID"
    elif [ -n "$APP_ID" ]; then
        print_info "Downloading app with app ID: $APP_ID"
        download_cmd="$download_cmd -i $APP_ID"
    else
        print_error "No valid identifier for download"
        exit 1
    fi

    log_verbose "Running: $download_cmd"

    if ! eval "$download_cmd"; then
        print_error "Failed to download app"
        echo ""
        echo "Common causes:"
        echo "  1. 'password token is expired' - Re-authenticate:"
        echo "     $ ipatool auth login --email your@email.com"
        echo ""
        echo "  2. 'temporarily unavailable' - The app either:"
        echo "     - Is not available in your Apple ID's region"
        echo "     - Has not been previously downloaded by your Apple ID"
        echo ""
        echo "  3. Region mismatch - Your Apple ID region must match the app's region"
        echo ""
        echo "Tips:"
        echo "  - Use apps you've already installed on your iOS devices"
        echo "  - Try searching: ipatool search 'App Name'"
        echo "  - Test with popular free apps from your region's App Store"
        exit 1
    fi

    if [ ! -f "app.ipa" ]; then
        print_error "IPA file not created"
        exit 1
    fi

    local ipa_size=$(du -h app.ipa | cut -f1)
    print_success "Downloaded app.ipa ($ipa_size)"
}

extract_app() {
    print_header "Extracting App"

    cd "$WORK_DIR"

    if [ -d "extracted" ]; then
        log_verbose "Removing old extraction..."
        rm -rf extracted
    fi

    mkdir -p extracted

    print_info "Extracting IPA..."
    if ! unzip -q app.ipa -d extracted 2>&1; then
        print_error "Failed to extract IPA"
        exit 1
    fi

    print_success "Extracted IPA"

    # Find the app bundle
    local app_bundle=$(find extracted/Payload -name "*.app" -type d | head -1)

    if [ -z "$app_bundle" ]; then
        print_error "Could not find .app bundle in IPA"
        exit 1
    fi

    APP_BUNDLE_PATH="$app_bundle"
    APP_BUNDLE_NAME=$(basename "$app_bundle" .app)

    # Also get the binary name (might be different from bundle name)
    APP_BINARY_NAME=$(plutil -extract CFBundleExecutable raw "$APP_BUNDLE_PATH/Info.plist" 2>/dev/null || echo "$APP_BUNDLE_NAME")

    log_verbose "App bundle: $APP_BUNDLE_PATH"
    print_success "Found app bundle: $APP_BUNDLE_NAME"
}

################################################################################
# Analysis Functions
################################################################################

get_app_info() {
    print_header "App Information"

    local info_plist="$APP_BUNDLE_PATH/Info.plist"

    if [ ! -f "$info_plist" ]; then
        print_warning "Info.plist not found"
        return
    fi

    APP_INFO_NAME=$(plutil -extract CFBundleName raw "$info_plist" 2>/dev/null || echo "N/A")
    APP_INFO_DISPLAY_NAME=$(plutil -extract CFBundleDisplayName raw "$info_plist" 2>/dev/null || echo "$APP_INFO_NAME")
    APP_INFO_BUNDLE_ID=$(plutil -extract CFBundleIdentifier raw "$info_plist" 2>/dev/null || echo "N/A")
    APP_INFO_VERSION=$(plutil -extract CFBundleShortVersionString raw "$info_plist" 2>/dev/null || echo "N/A")
    APP_INFO_BUILD=$(plutil -extract CFBundleVersion raw "$info_plist" 2>/dev/null || echo "N/A")

    echo "Name:         $APP_INFO_DISPLAY_NAME"
    echo "Bundle ID:    $APP_INFO_BUNDLE_ID"
    echo "Version:      $APP_INFO_VERSION"
    echo "Build:        $APP_INFO_BUILD"

    local app_size=$(du -sh "$APP_BUNDLE_PATH" 2>/dev/null | cut -f1)
    echo "Size:         $app_size"
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

    # Check all frameworks
    for details in "${ALL_FRAMEWORK_DETAILS[@]}"; do
        IFS='|' read -r fw_name fw_bundle fw_version fw_build fw_size <<< "$details"

        # Check if framework name or bundle ID matches any competitor
        for competitor in "${COMPETITOR_NAMES[@]}"; do
            # Create case-insensitive pattern
            local pattern=$(echo "$competitor" | sed 's/ /.*/g')

            if echo "$fw_name" | grep -iq "$pattern" || echo "$fw_bundle" | grep -iq "$pattern"; then
                local match_info="$fw_name|$fw_bundle|$fw_version|$fw_build|$fw_size|$competitor"
                COMPETITOR_PRODUCTS+=("$match_info")
                log_verbose "Found competitor match: $competitor in $fw_name"
                break
            fi
        done
    done

    if [ ${#COMPETITOR_PRODUCTS[@]} -gt 0 ]; then
        print_warning "Detected ${#COMPETITOR_PRODUCTS[@]} competitor product(s)"
    fi
}

list_all_frameworks() {
    print_header "Framework & Library Analysis"

    ALL_FRAMEWORKS=()
    ALL_FRAMEWORK_DETAILS=()
    COMPETITOR_NAMES=()

    # Load competitors list
    load_competitors

    # List all frameworks in Frameworks directory
    if [ -d "$APP_BUNDLE_PATH/Frameworks" ]; then
        echo -e "${BOLD}📦 Embedded Frameworks:${NC}\n"

        local framework_count=0
        while IFS= read -r framework; do
            if [ -z "$framework" ]; then
                continue
            fi

            framework_count=$((framework_count + 1))
            ALL_FRAMEWORKS+=("$framework")

            echo -e "${CYAN}${BOLD}$framework_count. $framework${NC}"

            local fw_path="$APP_BUNDLE_PATH/Frameworks/$framework"
            local fw_details=""

            # Get framework info
            if [ -f "$fw_path/Info.plist" ]; then
                local fw_bundle_id=$(plutil -extract CFBundleIdentifier raw "$fw_path/Info.plist" 2>/dev/null || echo "N/A")
                local fw_version=$(plutil -extract CFBundleShortVersionString raw "$fw_path/Info.plist" 2>/dev/null || echo "N/A")
                local fw_build=$(plutil -extract CFBundleVersion raw "$fw_path/Info.plist" 2>/dev/null || echo "N/A")

                echo "   Bundle ID: $fw_bundle_id"
                echo "   Version:   $fw_version (build $fw_build)"

                fw_details="$framework|$fw_bundle_id|$fw_version|$fw_build"
            else
                fw_details="$framework|N/A|N/A|N/A"
            fi

            # Get framework size
            if [ -d "$fw_path" ]; then
                local fw_size=$(du -sh "$fw_path" 2>/dev/null | cut -f1)
                echo "   Size:      $fw_size"
                fw_details="$fw_details|$fw_size"
            else
                fw_details="$fw_details|N/A"
            fi

            ALL_FRAMEWORK_DETAILS+=("$fw_details")
            echo ""
        done < <(ls "$APP_BUNDLE_PATH/Frameworks/" 2>/dev/null)

        if [ $framework_count -eq 0 ]; then
            echo "   (No embedded frameworks found)"
            echo ""
        else
            print_success "Found $framework_count embedded framework(s)"
        fi
    else
        echo -e "${BOLD}📦 Embedded Frameworks:${NC}\n"
        echo "   (No Frameworks directory found)"
        echo ""
    fi

    # Check for competitors
    check_for_competitors

    # Display competitor products if found
    if [ ${#COMPETITOR_PRODUCTS[@]} -gt 0 ]; then
        echo -e "\n${BOLD}${RED}⚠️  COMPETITOR PRODUCTS DETECTED:${NC}\n"

        local idx=1
        for match_info in "${COMPETITOR_PRODUCTS[@]}"; do
            IFS='|' read -r fw_name fw_bundle fw_version fw_build fw_size competitor <<< "$match_info"
            echo -e "${RED}${BOLD}$idx. $fw_name${NC}"
            echo "   Competitor:  $competitor"
            echo "   Bundle ID:   $fw_bundle"
            echo "   Version:     $fw_version (build $fw_build)"
            echo "   Size:        $fw_size"
            echo ""
            idx=$((idx + 1))
        done
    fi

    # List dynamic library dependencies
    echo -e "\n${BOLD}🔗 Dynamic Library Dependencies:${NC}\n"

    local binary_deps=$(otool -L "$APP_BUNDLE_PATH/$APP_BINARY_NAME" 2>/dev/null | tail -n +2 || true)

    if [ -n "$binary_deps" ]; then
        echo "$binary_deps" | while IFS= read -r dep; do
            if [ -n "$dep" ]; then
                local clean_dep=$(echo "$dep" | xargs | sed 's/ (compatibility.*//')
                echo "   • $clean_dep"
            fi
        done
        echo ""
    else
        echo "   (No dynamic libraries found)"
        echo ""
    fi

    # Summary
    if [ ${#COMPETITOR_PRODUCTS[@]} -gt 0 ]; then
        echo -e "${RED}${BOLD}⚠️  WARNING: Found ${#COMPETITOR_PRODUCTS[@]} competitor product(s)${NC}"
    fi
    echo -e "${GREEN}${BOLD}✅ Analysis complete${NC}"
}

detect_frameworks() {
    # If listing all frameworks, use the new function
    if [ "$LIST_ALL_FRAMEWORKS" = true ]; then
        list_all_frameworks
        return
    fi

    # Otherwise, search for specific SDKs
    print_header "SDK Detection"

    DETECTED_SDKS=()

    for sdk_name in "${SDK_NAMES[@]}"; do
        echo -e "\n${BOLD}Searching for: ${sdk_name}${NC}"

        local found=false
        local details=""

        # Method 1: Check Frameworks directory
        if [ -d "$APP_BUNDLE_PATH/Frameworks" ]; then
            log_verbose "Checking Frameworks directory..."
            local frameworks=$(ls "$APP_BUNDLE_PATH/Frameworks/" 2>/dev/null | grep -i "$sdk_name" || true)

            if [ -n "$frameworks" ]; then
                found=true
                print_found "Framework directory detected"

                while IFS= read -r framework; do
                    echo "  📦 $framework"

                    local fw_path="$APP_BUNDLE_PATH/Frameworks/$framework"
                    local fw_info=""

                    # Get framework info
                    if [ -f "$fw_path/Info.plist" ]; then
                        local fw_bundle_id=$(plutil -extract CFBundleIdentifier raw "$fw_path/Info.plist" 2>/dev/null || echo "N/A")
                        local fw_version=$(plutil -extract CFBundleShortVersionString raw "$fw_path/Info.plist" 2>/dev/null || echo "N/A")
                        local fw_build=$(plutil -extract CFBundleVersion raw "$fw_path/Info.plist" 2>/dev/null || echo "N/A")

                        echo "     Bundle ID: $fw_bundle_id"
                        echo "     Version:   $fw_version"
                        echo "     Build:     $fw_build"

                        fw_info="$framework (v$fw_version, build $fw_build)"
                    fi

                    # Get framework size
                    if [ -d "$fw_path" ]; then
                        local fw_size=$(du -sh "$fw_path" 2>/dev/null | cut -f1)
                        echo "     Size:      $fw_size"

                        if [ -n "$fw_info" ]; then
                            fw_info="$fw_info, size: $fw_size"
                        else
                            fw_info="$framework, size: $fw_size"
                        fi
                    fi

                    details="$details\n  - $fw_info"

                done <<< "$frameworks"
            fi
        fi

        # Method 2: Check dynamic library dependencies
        log_verbose "Checking binary dependencies..."
        local binary_deps=$(otool -L "$APP_BUNDLE_PATH/$APP_BINARY_NAME" 2>/dev/null | grep -i "$sdk_name" || true)

        if [ -n "$binary_deps" ]; then
            if [ "$found" = false ]; then
                found=true
            fi
            print_found "Binary dependency detected"
            echo "$binary_deps" | while IFS= read -r dep; do
                echo "  🔗 $(echo $dep | xargs)"
            done

            details="$details\n  - Binary links to $sdk_name framework"
        fi

        # Method 3: Search for SDK files
        log_verbose "Searching for files..."
        local sdk_files=$(find "$APP_BUNDLE_PATH" -type f -iname "*${sdk_name}*" 2>/dev/null | grep -v "_CodeSignature" | head -10 || true)

        if [ -n "$sdk_files" ]; then
            local file_count=$(echo "$sdk_files" | wc -l | tr -d ' ')
            if [ "$file_count" -gt 0 ]; then
                if [ "$found" = false ]; then
                    found=true
                fi
                print_found "Found $file_count file(s) with SDK name"
                if [ "$VERBOSE" = true ]; then
                    echo "$sdk_files" | head -5 | while IFS= read -r file; do
                        echo "  📄 $file"
                    done
                fi
            fi
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

    # Create filename with app bundle ID or name
    local report_filename="$OUTPUT_REPORT"

    # If user didn't specify custom output, add app identifier to filename
    if [ "$OUTPUT_REPORT" = "sdk-detection-report.txt" ]; then
        # Use bundle ID if available, otherwise use app name, sanitize for filename
        local identifier="${APP_INFO_BUNDLE_ID}"
        if [ -z "$identifier" ] || [ "$identifier" = "N/A" ]; then
            identifier="${APP_INFO_NAME}"
        fi

        # Sanitize identifier (replace dots, spaces with dashes, remove special chars)
        identifier=$(echo "$identifier" | tr '.' '-' | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')

        # Add timestamp to make it unique
        local timestamp=$(date +%Y%m%d-%H%M%S)

        if [ "$LIST_ALL_FRAMEWORKS" = true ]; then
            report_filename="framework-analysis-${identifier}-${timestamp}.txt"
        else
            report_filename="sdk-detection-${identifier}-${timestamp}.txt"
        fi
    fi

    # Save report to original directory, not work directory
    local report_file="$ORIGINAL_DIR/$report_filename"
    FINAL_REPORT_PATH="$report_file"

    # Generate different reports based on mode
    if [ "$LIST_ALL_FRAMEWORKS" = true ]; then
        generate_all_frameworks_report "$report_file"
    else
        generate_sdk_detection_report "$report_file"
    fi

    print_success "Report saved to: $report_file"

    # Also display report to console
    echo ""
    cat "$report_file"
}

generate_all_frameworks_report() {
    local report_file="$1"

    cat > "$report_file" << EOF
--------------------------------------------------------------------------------
iOS APP FRAMEWORK & LIBRARY ANALYSIS REPORT
--------------------------------------------------------------------------------

Generated: $(date "+%Y-%m-%d %H:%M:%S")
Analysis Tool: iOS SDK Detection Script v1.0

--------------------------------------------------------------------------------
APP INFORMATION
--------------------------------------------------------------------------------

Name:           $APP_INFO_DISPLAY_NAME
Bundle ID:      $APP_INFO_BUNDLE_ID
Version:        $APP_INFO_VERSION
Build:          $APP_INFO_BUILD
App Size:       $(du -sh "$APP_BUNDLE_PATH" | cut -f1)

EOF

    # Add competitor detection section if competitors found
    if [ ${#COMPETITOR_PRODUCTS[@]} -gt 0 ]; then
        cat >> "$report_file" << EOF
--------------------------------------------------------------------------------
⚠️  COMPETITOR PRODUCTS DETECTED
--------------------------------------------------------------------------------

WARNING: This app contains ${#COMPETITOR_PRODUCTS[@]} competitor product(s):

EOF
        local idx=1
        for match_info in "${COMPETITOR_PRODUCTS[@]}"; do
            IFS='|' read -r fw_name fw_bundle fw_version fw_build fw_size competitor <<< "$match_info"
            cat >> "$report_file" << EOF
$idx. $fw_name
   Competitor:  $competitor
   Bundle ID:   $fw_bundle
   Version:     $fw_version (build $fw_build)
   Size:        $fw_size

EOF
            idx=$((idx + 1))
        done

        cat >> "$report_file" << EOF

EOF
    fi

    cat >> "$report_file" << EOF
--------------------------------------------------------------------------------
EMBEDDED FRAMEWORKS
--------------------------------------------------------------------------------

EOF

    if [ ${#ALL_FRAMEWORKS[@]} -eq 0 ]; then
        cat >> "$report_file" << EOF
No embedded frameworks found in the app bundle.

EOF
    else
        cat >> "$report_file" << EOF
Found ${#ALL_FRAMEWORKS[@]} embedded framework(s):

EOF
        local idx=1
        for details in "${ALL_FRAMEWORK_DETAILS[@]}"; do
            IFS='|' read -r fw_name fw_bundle fw_version fw_build fw_size <<< "$details"
            cat >> "$report_file" << EOF
$idx. $fw_name
   Bundle ID: $fw_bundle
   Version:   $fw_version (build $fw_build)
   Size:      $fw_size

EOF
            idx=$((idx + 1))
        done
    fi

    cat >> "$report_file" << EOF
--------------------------------------------------------------------------------
DYNAMIC LIBRARY DEPENDENCIES
--------------------------------------------------------------------------------

EOF

    local binary_deps=$(otool -L "$APP_BUNDLE_PATH/$APP_BINARY_NAME" 2>/dev/null | tail -n +2 || true)
    if [ -n "$binary_deps" ]; then
        echo "$binary_deps" | while IFS= read -r dep; do
            if [ -n "$dep" ]; then
                local clean_dep=$(echo "$dep" | xargs | sed 's/ (compatibility.*//')
                echo "  • $clean_dep" >> "$report_file"
            fi
        done
    else
        echo "  (No dynamic libraries found)" >> "$report_file"
    fi

    cat >> "$report_file" << EOF

--------------------------------------------------------------------------------
ANALYSIS METHODS
--------------------------------------------------------------------------------

1. Framework Directory Inspection
   - Listed all frameworks in the Frameworks/ directory
   - Extracted version, bundle ID, and size information

2. Competitor Detection
   - Checked frameworks against known competitors list
   - Flagged any matches for review

3. Binary Dependency Analysis
   - Used otool -L to list all dynamic library dependencies
   - Shows both system frameworks and embedded libraries

--------------------------------------------------------------------------------
TECHNICAL DETAILS
--------------------------------------------------------------------------------

Analysis Directory: $WORK_DIR
App Bundle Path:    $APP_BUNDLE_PATH
Binary Name:        $APP_BINARY_NAME
IPA Size:           $(du -sh "$WORK_DIR/app.ipa" 2>/dev/null | cut -f1)
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
iOS APP SDK DETECTION REPORT
--------------------------------------------------------------------------------

Generated: $(date "+%Y-%m-%d %H:%M:%S")
Analysis Tool: iOS SDK Detection Script v1.0

--------------------------------------------------------------------------------
APP INFORMATION
--------------------------------------------------------------------------------

Name:           $APP_INFO_DISPLAY_NAME
Bundle ID:      $APP_INFO_BUNDLE_ID
Version:        $APP_INFO_VERSION
Build:          $APP_INFO_BUILD
App Size:       $(du -sh "$APP_BUNDLE_PATH" | cut -f1)

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

            # Get stored details
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

1. Framework Directory Inspection
   - Searched Frameworks/ directory for SDK frameworks
   - Extracted version and size information

2. Binary Dependency Analysis
   - Used otool to check dynamic library linkage
   - Verified runtime dependencies

3. File Search
   - Searched for files containing SDK names
   - Checked across entire app bundle

--------------------------------------------------------------------------------
CONCLUSION
--------------------------------------------------------------------------------

EOF

    if [ ${#DETECTED_SDKS[@]} -eq 0 ]; then
        cat >> "$report_file" << EOF
The analyzed app does NOT contain any of the specified SDKs.

If you expected to find these SDKs, consider:
- The SDK may be obfuscated or renamed
- The SDK may be statically linked (harder to detect)
- The SDK may have been removed in this version
- The search terms may need adjustment

EOF
    else
        cat >> "$report_file" << EOF
The analyzed app CONTAINS the following SDK(s): ${DETECTED_SDKS[*]}

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
App Bundle Path:    $APP_BUNDLE_PATH
IPA Size:           $(du -sh "$WORK_DIR/app.ipa" 2>/dev/null | cut -f1)

--------------------------------------------------------------------------------
END OF REPORT
--------------------------------------------------------------------------------
EOF
}

################################################################################
# Cleanup
################################################################################

cleanup() {
    # Always return to original directory
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
                LIST_ALL_FRAMEWORKS=true
                shift
                ;;
            -u|--url)
                APP_STORE_URL="$2"
                shift 2
                ;;
            -b|--bundle)
                BUNDLE_ID="$2"
                shift 2
                ;;
            -i|--app-id)
                APP_ID="$2"
                shift 2
                ;;
            -q|--search)
                SEARCH_TERM="$2"
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
    echo "║         iOS App SDK Detection Script v1.0                      ║"
    echo "║         License Compliance & Security Analysis                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"

    # Validate inputs
    validate_inputs

    # Check requirements
    check_requirements

    # Get app identifier
    get_app_identifier

    # Download app
    download_app

    # Extract app
    extract_app

    # Get app info
    get_app_info

    # Detect SDKs
    detect_frameworks

    # Generate report
    generate_report

    # Cleanup
    cleanup

    # Final summary
    print_header "Analysis Complete"

    if [ "$LIST_ALL_FRAMEWORKS" = true ]; then
        if [ ${#ALL_FRAMEWORKS[@]} -eq 0 ]; then
            echo -e "${YELLOW}${BOLD}No embedded frameworks found${NC}"
        else
            echo -e "${GREEN}${BOLD}Found ${#ALL_FRAMEWORKS[@]} embedded framework(s)${NC}"
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
