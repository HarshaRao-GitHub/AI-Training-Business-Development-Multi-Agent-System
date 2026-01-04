#!/bin/bash

# BD Assistant iOS App - Build Script
# This script builds the iOS app for sideloading

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_NAME="BDAssistant"
SCHEME="BDAssistant"
BUILD_DIR="${PROJECT_DIR}/build"
ARCHIVE_PATH="${BUILD_DIR}/${PROJECT_NAME}.xcarchive"
IPA_PATH="${BUILD_DIR}/${PROJECT_NAME}.ipa"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  BD Assistant iOS Build Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: Xcode command line tools not found${NC}"
    echo "Please install Xcode from the App Store"
    exit 1
fi

echo -e "${GREEN}✓ Xcode found${NC}"

# Check Xcode version
XCODE_VERSION=$(xcodebuild -version | head -n 1)
echo -e "${BLUE}Using: ${XCODE_VERSION}${NC}"
echo ""

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Build for device
echo -e "${YELLOW}Building for iOS device...${NC}"
echo ""

xcodebuild \
    -project "${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath "${ARCHIVE_PATH}" \
    archive \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    | xcpretty --color || xcodebuild \
    -project "${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath "${ARCHIVE_PATH}" \
    archive \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

if [ ! -d "${ARCHIVE_PATH}" ]; then
    echo -e "${RED}Error: Archive failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Archive created${NC}"
echo ""

# Create IPA for sideloading
echo -e "${YELLOW}Creating IPA for sideloading...${NC}"

# Create Payload directory
PAYLOAD_DIR="${BUILD_DIR}/Payload"
mkdir -p "${PAYLOAD_DIR}"

# Copy app to Payload
APP_PATH="${ARCHIVE_PATH}/Products/Applications/${PROJECT_NAME}.app"
if [ -d "${APP_PATH}" ]; then
    cp -r "${APP_PATH}" "${PAYLOAD_DIR}/"
else
    # Alternative location
    APP_PATH=$(find "${ARCHIVE_PATH}" -name "*.app" -type d | head -n 1)
    if [ -n "${APP_PATH}" ]; then
        cp -r "${APP_PATH}" "${PAYLOAD_DIR}/"
    else
        echo -e "${RED}Error: Could not find .app bundle${NC}"
        exit 1
    fi
fi

# Create IPA
cd "${BUILD_DIR}"
zip -r "${PROJECT_NAME}.ipa" Payload
rm -rf Payload

echo -e "${GREEN}✓ IPA created: ${IPA_PATH}${NC}"
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Build Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Output files:"
echo -e "  Archive: ${ARCHIVE_PATH}"
echo -e "  IPA:     ${IPA_PATH}"
echo ""
echo -e "${YELLOW}Next steps for sideloading:${NC}"
echo -e "  1. Install AltServer on your Mac"
echo -e "  2. Connect your iPhone via USB"
echo -e "  3. Use AltStore to install the IPA"
echo ""
echo -e "Or use Xcode directly:"
echo -e "  1. Open ${PROJECT_NAME}.xcodeproj in Xcode"
echo -e "  2. Connect your iPhone"
echo -e "  3. Select your device and click Run"
echo ""
