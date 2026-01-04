#!/bin/bash

# BD Assistant - AltStore Installation Helper
# This script helps set up AltStore for sideloading

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  AltStore Setup Helper${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS="Windows"
else
    echo -e "${RED}Unsupported operating system${NC}"
    echo "AltStore is only available for macOS and Windows"
    exit 1
fi

echo -e "Detected OS: ${GREEN}${OS}${NC}"
echo ""

if [ "$OS" == "macOS" ]; then
    echo -e "${YELLOW}Setting up AltStore for macOS...${NC}"
    echo ""

    # Check if AltServer is installed
    if [ -d "/Applications/AltServer.app" ]; then
        echo -e "${GREEN}✓ AltServer is already installed${NC}"
    else
        echo -e "AltServer is not installed."
        echo ""
        echo -e "${BLUE}To install AltServer:${NC}"
        echo "1. Visit https://altstore.io"
        echo "2. Download AltServer for macOS"
        echo "3. Move AltServer.app to /Applications"
        echo "4. Open AltServer from Applications"
        echo ""

        read -p "Would you like to open the download page? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            open "https://altstore.io"
        fi
    fi

    echo ""
    echo -e "${BLUE}Installation Steps:${NC}"
    echo ""
    echo "1. Make sure AltServer is running (check menu bar)"
    echo "2. Connect your iPhone via USB"
    echo "3. Trust your computer on your iPhone if prompted"
    echo "4. Click AltServer in menu bar → Install AltStore → [Your iPhone]"
    echo "5. Enter your Apple ID when prompted"
    echo "6. Wait for AltStore to install on your iPhone"
    echo ""
    echo -e "${YELLOW}After AltStore is installed:${NC}"
    echo ""
    echo "1. On your iPhone, go to Settings → General → VPN & Device Management"
    echo "2. Trust the developer certificate"
    echo "3. Open AltStore on your iPhone"
    echo "4. Go to 'My Apps' tab"
    echo "5. Tap '+' and select the BDAssistant.ipa file"
    echo ""

else
    echo -e "${YELLOW}Setting up AltStore for Windows...${NC}"
    echo ""
    echo -e "${BLUE}Prerequisites:${NC}"
    echo "1. iTunes (Windows Store version or from Apple website)"
    echo "2. iCloud for Windows"
    echo ""
    echo -e "${BLUE}To install AltServer:${NC}"
    echo "1. Visit https://altstore.io"
    echo "2. Download AltServer for Windows"
    echo "3. Extract and run AltServer.exe"
    echo ""
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Sideloading the BD Assistant App${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Once AltStore is set up on your iPhone:"
echo ""
echo "Option 1: Via AltStore"
echo "  1. Transfer BDAssistant.ipa to your iPhone (AirDrop, iCloud, etc.)"
echo "  2. Open AltStore → My Apps → '+' → Select the IPA"
echo ""
echo "Option 2: Via AltServer (easier)"
echo "  1. Keep your iPhone connected to your computer"
echo "  2. Right-click AltServer → Install App → Choose IPA"
echo "  3. Select your iPhone"
echo ""
echo "Option 3: Via Xcode (requires Apple Developer account)"
echo "  1. Open BDAssistant.xcodeproj in Xcode"
echo "  2. Connect your iPhone"
echo "  3. Set your development team in project settings"
echo "  4. Click Run to build and install"
echo ""
echo -e "${YELLOW}Note: Free Apple IDs require re-signing every 7 days${NC}"
echo "AltStore can automatically refresh the app if your iPhone"
echo "connects to the same WiFi network as your computer."
echo ""
