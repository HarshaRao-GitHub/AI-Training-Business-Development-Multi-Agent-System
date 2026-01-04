# BD Assistant - Native iOS App

A native SwiftUI iOS app for the AI Training Business Development Multi-Agent System. This app can be **sideloaded** onto any iPhone without going through the App Store.

## Features

### Core Functionality
- **Dashboard** - Real-time metrics, agent status, and today's priorities
- **Lead Management** - View, qualify, and manage leads on the go
- **Proposal Generation** - Create AI-powered proposals from your phone
- **Intelligence Briefs** - Daily AI-generated market intelligence
- **Voice Notes** - Record meeting notes for AI transcription

### iOS-Specific Features
- **Offline Support** - Full CoreData caching for offline access
- **Push Notifications** - Morning briefs, hot lead alerts, proposal views
- **Home Screen Widgets** - Quick metrics at a glance
- **Apple Watch App** - Check leads and metrics from your wrist
- **Biometric Auth** - Face ID / Touch ID support

## Requirements

- iPhone running iOS 17.0 or later
- macOS with Xcode 15+ (for building)
- Connection to your BD Assistant backend server

## Sideloading Options

### Option 1: AltStore (Recommended for Most Users)

AltStore allows you to install apps without a paid developer account.

1. **Install AltServer on your Mac/PC**
   - Download from [altstore.io](https://altstore.io)
   - Install and run AltServer

2. **Install AltStore on your iPhone**
   - Connect your iPhone via USB
   - Click AltServer in menu bar → Install AltStore
   - Enter your Apple ID

3. **Install BD Assistant**
   - Build the app: `./Scripts/build.sh`
   - Transfer `build/BDAssistant.ipa` to your iPhone
   - Open in AltStore → Install

> **Note:** Free Apple IDs require re-signing every 7 days. Keep AltServer running and your iPhone on the same WiFi for automatic refresh.

### Option 2: Xcode Direct Install (For Developers)

1. **Open in Xcode**
   ```bash
   open BDAssistant.xcodeproj
   ```

2. **Configure signing**
   - Select the project in Xcode
   - Go to Signing & Capabilities
   - Select your Team (free or paid Apple Developer account)

3. **Install on device**
   - Connect your iPhone
   - Select your device as the build target
   - Click Run (⌘R)

### Option 3: Enterprise Distribution

For organizations with an Apple Developer Enterprise Program ($299/year):

1. Build with enterprise certificate
2. Host IPA on internal server
3. Users install via Safari link
4. No 7-day refresh required

## Project Structure

```
ios-app/
├── BDAssistant.xcodeproj/          # Xcode project
├── BDAssistant/
│   ├── Info.plist                  # App configuration
│   ├── Assets.xcassets/            # Images and colors
│   └── Sources/
│       ├── App/                    # App entry point
│       ├── Views/                  # SwiftUI views
│       │   ├── Dashboard/
│       │   ├── Leads/
│       │   ├── Proposals/
│       │   ├── Intelligence/
│       │   ├── Settings/
│       │   └── Components/
│       ├── ViewModels/             # View models
│       ├── Models/                 # Data models
│       ├── Services/               # API and services
│       ├── CoreData/               # Offline storage
│       └── Extensions/             # Swift extensions
├── BDAssistantWidget/              # Home screen widgets
├── BDAssistantWatch/               # Apple Watch app
├── Scripts/
│   ├── build.sh                    # Build IPA
│   ├── install-altstore.sh         # AltStore setup
│   └── setup-dev.sh                # Dev environment
└── README.md
```

## Building from Source

### Prerequisites

- macOS 13+ (Ventura or later)
- Xcode 15+
- Command Line Tools: `xcode-select --install`

### Setup

```bash
# Navigate to iOS app directory
cd ios-app

# Set up development environment
./Scripts/setup-dev.sh

# Build the IPA
./Scripts/build.sh
```

### Build Outputs

- **Archive:** `build/BDAssistant.xcarchive`
- **IPA:** `build/BDAssistant.ipa`

## Configuration

### Server Connection

On first launch, enter your BD Assistant backend URL:

```
https://your-server.com:8000
```

The app will connect to the FastAPI backend and sync data.

### Offline Mode

The app caches all data locally using CoreData:
- Leads, proposals, and briefs are available offline
- Changes sync when connection is restored
- Toggle offline mode in Settings for airplane mode

### Notifications

Configure in Settings → Notifications:
- **Morning Brief:** Daily intelligence at your preferred time
- **Hot Lead Alerts:** Instant notification for high-score leads
- **Proposal Views:** Know when clients view proposals

## Widgets

Add widgets to your home screen:

1. Long-press on home screen
2. Tap "+" in top left
3. Search "BD Assistant"
4. Choose widget size:
   - **Small:** Hot leads count
   - **Medium:** Pipeline metrics
   - **Large:** Full dashboard with next action

## Apple Watch

The companion Watch app provides:
- Quick metrics overview
- Top hot leads list
- Next action reminder
- Call/email shortcuts

## API Integration

The app connects to all 7 backend agents:

| Agent | Mobile Features |
|-------|----------------|
| Orchestrator | Daily routine, task coordination |
| Research | Intelligence briefs, market research |
| Lead Gen | Lead qualification, enrichment |
| Content | Proposal generation |
| Relationship | Follow-up reminders |
| Knowledge | Case study search |
| Analytics | Pipeline metrics |

## Troubleshooting

### App Won't Install

1. **AltStore:** Ensure AltServer is running and iPhone is connected
2. **Xcode:** Check that your Apple ID is configured in Preferences → Accounts
3. **Enterprise:** Verify certificate hasn't expired

### App Expired (7-day limit)

1. Connect iPhone to same WiFi as Mac running AltServer
2. Open AltStore on iPhone
3. It will automatically refresh the app

### Can't Connect to Server

1. Verify backend is running: `curl http://your-server:8000/health`
2. Check iPhone is on same network or has internet access
3. Verify URL format includes `http://` or `https://`

### Offline Data Not Syncing

1. Check network connectivity
2. Go to Settings → Data → Force Sync
3. Pull-to-refresh on any list view

## Security Notes

- All data is stored locally on device
- API communication uses HTTPS
- Credentials stored in iOS Keychain
- Biometric auth available for app access

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test on device
5. Submit pull request

## License

This iOS app is part of the AI Training Business Development Multi-Agent System.
