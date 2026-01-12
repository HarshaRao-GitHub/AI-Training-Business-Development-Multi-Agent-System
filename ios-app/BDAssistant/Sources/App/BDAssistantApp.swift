//
//  BDAssistantApp.swift
//  BD Assistant - AI-Powered Business Development
//
//  Native iOS app for the AI Training Business Development Multi-Agent System
//  Designed for sideloading via AltStore, Xcode, or Enterprise distribution
//

import SwiftUI
import UserNotifications

@main
struct BDAssistantApp: App {
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    let persistenceController = PersistenceController.shared

    init() {
        configureAppearance()
        requestNotificationPermissions()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    appState.initialize()
                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                appState.refreshData()
            case .background:
                persistenceController.save()
                scheduleBackgroundTasks()
            case .inactive:
                break
            @unknown default:
                break
            }
        }
    }

    private func configureAppearance() {
        // Configure navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor.systemBackground
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance

        // Configure tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    private func scheduleBackgroundTasks() {
        // Schedule background refresh for intelligence briefs
        // Implementation would use BGTaskScheduler
    }
}

// MARK: - App State
@MainActor
class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var serverURL: String = ""
    @Published var lastSyncDate: Date?
    @Published var hasUnreadBriefs = false
    @Published var hotLeadsCount = 0
    @Published var pendingProposals = 0

    private let apiClient = APIClient.shared
    private let defaults = UserDefaults.standard

    func initialize() {
        loadSettings()
        if !serverURL.isEmpty {
            refreshData()
        }
    }

    func loadSettings() {
        serverURL = defaults.string(forKey: "serverURL") ?? ""
        isAuthenticated = defaults.bool(forKey: "isAuthenticated")

        if let lastSync = defaults.object(forKey: "lastSyncDate") as? Date {
            lastSyncDate = lastSync
        }
    }

    func saveSettings() {
        defaults.set(serverURL, forKey: "serverURL")
        defaults.set(isAuthenticated, forKey: "isAuthenticated")
        defaults.set(lastSyncDate, forKey: "lastSyncDate")
    }

    func connect(to url: String) async throws {
        serverURL = url
        apiClient.configure(baseURL: url)

        // Test connection
        let health = try await apiClient.healthCheck()
        if health.status == "healthy" {
            isAuthenticated = true
            lastSyncDate = Date()
            saveSettings()
            await refreshDataAsync()
        }
    }

    func refreshData() {
        Task {
            await refreshDataAsync()
        }
    }

    private func refreshDataAsync() async {
        guard isAuthenticated else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            // Fetch dashboard metrics
            let metrics = try await apiClient.getDashboardMetrics()
            hotLeadsCount = metrics.hotLeads
            pendingProposals = metrics.pendingProposals
            hasUnreadBriefs = metrics.hasUnreadBriefs
            lastSyncDate = Date()
            saveSettings()
        } catch {
            print("Failed to refresh data: \(error)")
        }
    }

    func logout() {
        isAuthenticated = false
        serverURL = ""
        saveSettings()
    }
}
