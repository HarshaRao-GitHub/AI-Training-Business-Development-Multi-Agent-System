#!/bin/bash

# BD Assistant - Development Environment Setup
# Sets up the iOS app development environment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  BD Assistant Development Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check for macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}This script requires macOS with Xcode${NC}"
    echo "iOS development is only supported on macOS"
    exit 1
fi

# Check for Xcode
echo -e "${YELLOW}Checking Xcode installation...${NC}"
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Xcode is not installed${NC}"
    echo "Please install Xcode from the App Store"
    exit 1
fi
echo -e "${GREEN}✓ Xcode installed${NC}"

# Check Xcode version
XCODE_VERSION=$(xcodebuild -version | head -n 1)
echo -e "  ${XCODE_VERSION}"
echo ""

# Check for Xcode Command Line Tools
echo -e "${YELLOW}Checking Xcode Command Line Tools...${NC}"
if ! xcode-select -p &> /dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Please complete the installation and run this script again"
    exit 1
fi
echo -e "${GREEN}✓ Command Line Tools installed${NC}"
echo ""

# Accept Xcode license if needed
echo -e "${YELLOW}Checking Xcode license...${NC}"
if ! sudo xcodebuild -license check &> /dev/null; then
    echo "Please accept the Xcode license:"
    sudo xcodebuild -license accept
fi
echo -e "${GREEN}✓ Xcode license accepted${NC}"
echo ""

# Install xcpretty for nicer build output (optional)
echo -e "${YELLOW}Checking for xcpretty...${NC}"
if command -v xcpretty &> /dev/null; then
    echo -e "${GREEN}✓ xcpretty installed${NC}"
else
    echo "xcpretty not found (optional, for nicer build output)"
    read -p "Would you like to install it? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo gem install xcpretty
        echo -e "${GREEN}✓ xcpretty installed${NC}"
    fi
fi
echo ""

# Check for SwiftLint (optional)
echo -e "${YELLOW}Checking for SwiftLint...${NC}"
if command -v swiftlint &> /dev/null; then
    echo -e "${GREEN}✓ SwiftLint installed${NC}"
else
    echo "SwiftLint not found (optional, for code linting)"
    read -p "Would you like to install it via Homebrew? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v brew &> /dev/null; then
            brew install swiftlint
            echo -e "${GREEN}✓ SwiftLint installed${NC}"
        else
            echo -e "${YELLOW}Homebrew not found. Skipping SwiftLint installation.${NC}"
        fi
    fi
fi
echo ""

# Generate Xcode project assets
echo -e "${YELLOW}Setting up project assets...${NC}"

# Create Assets.xcassets structure if not exists
ASSETS_DIR="${PROJECT_DIR}/BDAssistant/Assets.xcassets"
mkdir -p "${ASSETS_DIR}"

# Create Contents.json for Assets
cat > "${ASSETS_DIR}/Contents.json" << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create AccentColor
mkdir -p "${ASSETS_DIR}/AccentColor.colorset"
cat > "${ASSETS_DIR}/AccentColor.colorset/Contents.json" << 'EOF'
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.918",
          "green" : "0.486",
          "red" : "0.231"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create AppIcon placeholder
mkdir -p "${ASSETS_DIR}/AppIcon.appiconset"
cat > "${ASSETS_DIR}/AppIcon.appiconset/Contents.json" << 'EOF'
{
  "images" : [
    {
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo -e "${GREEN}✓ Asset catalogs created${NC}"
echo ""

# Validate project structure
echo -e "${YELLOW}Validating project structure...${NC}"
REQUIRED_FILES=(
    "BDAssistant.xcodeproj/project.pbxproj"
    "BDAssistant/Info.plist"
    "BDAssistant/Sources/App/BDAssistantApp.swift"
    "BDAssistant/Sources/App/ContentView.swift"
)

ALL_GOOD=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "${PROJECT_DIR}/${file}" ]; then
        echo -e "  ${GREEN}✓${NC} ${file}"
    else
        echo -e "  ${RED}✗${NC} ${file} (missing)"
        ALL_GOOD=false
    fi
done
echo ""

if [ "$ALL_GOOD" = true ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Setup Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "You can now:"
    echo -e "  1. Open the project in Xcode:"
    echo -e "     ${BLUE}open ${PROJECT_DIR}/BDAssistant.xcodeproj${NC}"
    echo ""
    echo -e "  2. Build from command line:"
    echo -e "     ${BLUE}./Scripts/build.sh${NC}"
    echo ""
    echo -e "  3. Run tests:"
    echo -e "     ${BLUE}xcodebuild test -scheme BDAssistant -destination 'platform=iOS Simulator,name=iPhone 15'${NC}"
    echo ""
else
    echo -e "${YELLOW}Some files are missing. The project may need additional setup.${NC}"
fi
