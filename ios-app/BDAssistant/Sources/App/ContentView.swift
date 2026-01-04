//
//  ContentView.swift
//  BD Assistant
//
//  Main navigation container with tab-based interface
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var showingSettings = false

    var body: some View {
        Group {
            if appState.isAuthenticated {
                mainTabView
            } else {
                OnboardingView()
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2")
                }
                .tag(0)

            LeadsListView()
                .tabItem {
                    Label("Leads", systemImage: "person.3")
                }
                .tag(1)
                .badge(appState.hotLeadsCount)

            ProposalsView()
                .tabItem {
                    Label("Proposals", systemImage: "doc.text")
                }
                .tag(2)
                .badge(appState.pendingProposals)

            IntelligenceBriefView()
                .tabItem {
                    Label("Intel", systemImage: "brain")
                }
                .tag(3)
                .badge(appState.hasUnreadBriefs ? "!" : nil)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .tint(.blue)
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var serverURL = ""
    @State private var isConnecting = false
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Logo and Title
                VStack(spacing: 16) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue.gradient)

                    Text("BD Assistant")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("AI-Powered Business Development")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Connection Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Server URL")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("https://your-server.com", text: $serverURL)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.URL)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }

                    Button(action: connect) {
                        HStack {
                            if isConnecting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Connect")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(serverURL.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(serverURL.isEmpty || isConnecting)

                    // Demo Mode
                    Button("Try Demo Mode") {
                        serverURL = "http://localhost:8000"
                        connect()
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 32)

                Spacer()

                // Info
                VStack(spacing: 8) {
                    Text("Sideloaded App")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("Connect to your AI Business Development server")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 32)
            }
            .navigationBarHidden(true)
            .alert("Connection Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Failed to connect to server")
            }
        }
    }

    private func connect() {
        isConnecting = true
        errorMessage = nil

        Task {
            do {
                try await appState.connect(to: serverURL)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isConnecting = false
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
