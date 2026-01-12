//
//  SettingsView.swift
//  BD Assistant
//
//  App settings and configuration
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var notificationService = NotificationService.shared
    @AppStorage("enableMorningBrief") private var enableMorningBrief = true
    @AppStorage("morningBriefHour") private var morningBriefHour = 8
    @AppStorage("enableHotLeadAlerts") private var enableHotLeadAlerts = true
    @AppStorage("enableProposalAlerts") private var enableProposalAlerts = true
    @AppStorage("offlineMode") private var offlineMode = false

    @State private var showingDisconnectAlert = false
    @State private var showingClearCacheAlert = false

    var body: some View {
        NavigationStack {
            List {
                // Connection Section
                Section {
                    HStack {
                        Image(systemName: "server.rack")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text("Server")
                                .font(.subheadline)
                            Text(appState.serverURL)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Circle()
                            .fill(appState.isAuthenticated ? .green : .red)
                            .frame(width: 10, height: 10)
                    }

                    if let lastSync = appState.lastSyncDate {
                        HStack {
                            Text("Last Synced")
                            Spacer()
                            Text(lastSync.formatted(.relative(presentation: .named)))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button("Refresh Connection") {
                        appState.refreshData()
                    }
                } header: {
                    Text("Connection")
                }

                // Notifications Section
                Section {
                    Toggle(isOn: $enableMorningBrief) {
                        Label("Morning Brief", systemImage: "sun.max")
                    }
                    .onChange(of: enableMorningBrief) { _, newValue in
                        if newValue {
                            notificationService.scheduleMorningBriefNotification(at: morningBriefHour)
                        } else {
                            notificationService.cancelNotification(identifier: "morning-brief")
                        }
                    }

                    if enableMorningBrief {
                        Picker("Brief Time", selection: $morningBriefHour) {
                            ForEach(5..<12, id: \.self) { hour in
                                Text("\(hour):00 AM").tag(hour)
                            }
                        }
                        .onChange(of: morningBriefHour) { _, newValue in
                            notificationService.scheduleMorningBriefNotification(at: newValue)
                        }
                    }

                    Toggle(isOn: $enableHotLeadAlerts) {
                        Label("Hot Lead Alerts", systemImage: "flame")
                    }

                    Toggle(isOn: $enableProposalAlerts) {
                        Label("Proposal Viewed Alerts", systemImage: "eye")
                    }

                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label("Advanced Notifications", systemImage: "bell.badge")
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Receive timely alerts for important business development activities.")
                }

                // Data Section
                Section {
                    Toggle(isOn: $offlineMode) {
                        Label("Offline Mode", systemImage: "wifi.slash")
                    }

                    Button(action: { showingClearCacheAlert = true }) {
                        Label("Clear Cache", systemImage: "trash")
                            .foregroundStyle(.red)
                    }

                    NavigationLink {
                        DataManagementView()
                    } label: {
                        Label("Data Management", systemImage: "externaldrive")
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("Offline mode uses cached data and syncs when connected.")
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundStyle(.secondary)
                    }

                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About BD Assistant", systemImage: "info.circle")
                    }

                    Link(destination: URL(string: "https://github.com/your-org/bd-assistant")!) {
                        Label("View on GitHub", systemImage: "link")
                    }
                } header: {
                    Text("About")
                }

                // Account Section
                Section {
                    Button(action: { showingDisconnectAlert = true }) {
                        Label("Disconnect", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Disconnect", isPresented: $showingDisconnectAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Disconnect", role: .destructive) {
                    appState.logout()
                }
            } message: {
                Text("Are you sure you want to disconnect from the server?")
            }
            .alert("Clear Cache", isPresented: $showingClearCacheAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    PersistenceController.shared.clearCache()
                }
            } message: {
                Text("This will remove all cached data. You'll need to sync again when connected.")
            }
        }
    }
}

// MARK: - Notification Settings View
struct NotificationSettingsView: View {
    @StateObject private var notificationService = NotificationService.shared

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Notification Status")
                    Spacer()
                    Text(notificationService.isAuthorized ? "Enabled" : "Disabled")
                        .foregroundStyle(notificationService.isAuthorized ? .green : .red)
                }

                if !notificationService.isAuthorized {
                    Button("Enable in Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }

            Section {
                Button("Test Morning Brief") {
                    // Send test notification
                    let content = UNMutableNotificationContent()
                    content.title = "Good Morning!"
                    content.body = "This is a test of your morning brief notification."
                    content.sound = .default

                    let request = UNNotificationRequest(
                        identifier: "test-morning",
                        content: content,
                        trigger: UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
                    )

                    UNUserNotificationCenter.current().add(request)
                }

                Button("Test Hot Lead Alert") {
                    let content = UNMutableNotificationContent()
                    content.title = "Hot Lead Alert! 🔥"
                    content.body = "Test Company has been qualified as a hot lead."
                    content.sound = .default

                    let request = UNNotificationRequest(
                        identifier: "test-hot-lead",
                        content: content,
                        trigger: UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
                    )

                    UNUserNotificationCenter.current().add(request)
                }
            } header: {
                Text("Test Notifications")
            } footer: {
                Text("Notifications will appear in 3 seconds")
            }

            Section {
                Button("Cancel All Notifications", role: .destructive) {
                    notificationService.cancelAllNotifications()
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Data Management View
struct DataManagementView: View {
    @State private var cacheSize = "Calculating..."
    @State private var leadCount = 0
    @State private var proposalCount = 0
    @State private var briefCount = 0

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Cache Size")
                    Spacer()
                    Text(cacheSize)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Cached Leads")
                    Spacer()
                    Text("\(leadCount)")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Cached Proposals")
                    Spacer()
                    Text("\(proposalCount)")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Cached Briefs")
                    Spacer()
                    Text("\(briefCount)")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Storage")
            }

            Section {
                Button("Export Data") {
                    // Export implementation
                }

                Button("Force Sync") {
                    Task {
                        await LeadService.shared.syncPendingChanges()
                    }
                }
            }
        }
        .navigationTitle("Data Management")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            calculateStorageInfo()
        }
    }

    private func calculateStorageInfo() {
        // Calculate storage info
        leadCount = PersistenceController.shared.getCachedLeads().count
        // Add other counts...
        cacheSize = "< 1 MB"
    }
}

// MARK: - About View
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Logo
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)
                    .padding(.top, 40)

                VStack(spacing: 8) {
                    Text("BD Assistant")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("AI-Powered Business Development")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .padding(.horizontal, 40)

                VStack(alignment: .leading, spacing: 16) {
                    AboutFeatureRow(
                        icon: "cpu",
                        title: "7 AI Agents",
                        description: "Specialized agents for research, lead gen, proposals, and more"
                    )

                    AboutFeatureRow(
                        icon: "icloud",
                        title: "Offline Support",
                        description: "Work anywhere with full offline capability"
                    )

                    AboutFeatureRow(
                        icon: "bell",
                        title: "Smart Notifications",
                        description: "Stay updated on leads, proposals, and market intelligence"
                    )

                    AboutFeatureRow(
                        icon: "lock.shield",
                        title: "Privacy First",
                        description: "Your data stays on your device and server"
                    )
                }
                .padding(.horizontal, 24)

                Spacer()

                Text("Sideloaded Native iOS App")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 20)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
