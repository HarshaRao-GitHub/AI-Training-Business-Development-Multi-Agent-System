//
//  NotificationService.swift
//  BD Assistant
//
//  Local and push notification management
//

import Foundation
import UserNotifications

@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var isAuthorized = false
    @Published var pendingNotifications: [UNNotificationRequest] = []

    private let center = UNUserNotificationCenter.current()

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    func checkAuthorizationStatus() {
        center.getNotificationSettings { settings in
            Task { @MainActor in
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Morning Brief Notification
    func scheduleMorningBriefNotification(at hour: Int = 8, minute: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = "Good Morning!"
        content.body = "Your daily intelligence brief is ready. Tap to view today's priorities."
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "MORNING_BRIEF"

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "morning-brief",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule morning brief: \(error)")
            }
        }
    }

    // MARK: - Lead Follow-up Reminder
    func scheduleFollowUpReminder(for lead: Lead) {
        guard let nextActionDate = lead.nextActionDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "Follow-up Reminder"
        content.body = "\(lead.companyName): \(lead.nextAction ?? "Time for follow-up")"
        content.sound = .default
        content.categoryIdentifier = "FOLLOW_UP"
        content.userInfo = ["leadId": lead.id]

        // Schedule 1 hour before
        let reminderDate = nextActionDate.addingTimeInterval(-3600)
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "follow-up-\(lead.id)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule follow-up: \(error)")
            }
        }
    }

    // MARK: - Hot Lead Alert
    func sendHotLeadAlert(lead: Lead) {
        let content = UNMutableNotificationContent()
        content.title = "Hot Lead Alert! 🔥"
        content.body = "\(lead.companyName) has been qualified as a hot lead with a score of \(lead.qualificationScore ?? 0)."
        content.sound = .default
        content.categoryIdentifier = "HOT_LEAD"
        content.userInfo = ["leadId": lead.id]

        let request = UNNotificationRequest(
            identifier: "hot-lead-\(lead.id)",
            content: content,
            trigger: nil // Immediate
        )

        center.add(request)
    }

    // MARK: - Proposal Viewed
    func sendProposalViewedNotification(proposal: Proposal, companyName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Proposal Viewed"
        content.body = "\(companyName) just viewed your proposal: \(proposal.title)"
        content.sound = .default
        content.categoryIdentifier = "PROPOSAL_VIEWED"
        content.userInfo = ["proposalId": proposal.id]

        let request = UNNotificationRequest(
            identifier: "proposal-viewed-\(proposal.id)",
            content: content,
            trigger: nil
        )

        center.add(request)
    }

    // MARK: - New Intelligence Brief
    func sendNewBriefNotification(brief: IntelligenceBrief) {
        let content = UNMutableNotificationContent()
        content.title = brief.briefType.displayName
        content.body = brief.title
        content.sound = brief.priority == .high ? .defaultCritical : .default
        content.categoryIdentifier = "INTEL_BRIEF"
        content.userInfo = ["briefId": brief.id]

        if brief.priority == .high {
            content.interruptionLevel = .timeSensitive
        }

        let request = UNNotificationRequest(
            identifier: "brief-\(brief.id)",
            content: content,
            trigger: nil
        )

        center.add(request)
    }

    // MARK: - Cancel Notifications
    func cancelNotification(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    func cancelAllFollowUpReminders() {
        center.getPendingNotificationRequests { requests in
            let followUpIds = requests
                .filter { $0.identifier.hasPrefix("follow-up-") }
                .map { $0.identifier }

            self.center.removePendingNotificationRequests(withIdentifiers: followUpIds)
        }
    }

    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    // MARK: - Badge Management
    func updateBadgeCount(_ count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count)
    }

    func clearBadge() {
        updateBadgeCount(0)
    }

    // MARK: - Notification Categories
    func registerCategories() {
        // Morning Brief Actions
        let viewBriefAction = UNNotificationAction(
            identifier: "VIEW_BRIEF",
            title: "View Brief",
            options: .foreground
        )

        let morningBriefCategory = UNNotificationCategory(
            identifier: "MORNING_BRIEF",
            actions: [viewBriefAction],
            intentIdentifiers: []
        )

        // Follow-up Actions
        let callAction = UNNotificationAction(
            identifier: "CALL_LEAD",
            title: "Call",
            options: .foreground
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_REMINDER",
            title: "Snooze 1 Hour",
            options: []
        )

        let followUpCategory = UNNotificationCategory(
            identifier: "FOLLOW_UP",
            actions: [callAction, snoozeAction],
            intentIdentifiers: []
        )

        // Hot Lead Actions
        let viewLeadAction = UNNotificationAction(
            identifier: "VIEW_LEAD",
            title: "View Lead",
            options: .foreground
        )

        let generateProposalAction = UNNotificationAction(
            identifier: "GENERATE_PROPOSAL",
            title: "Generate Proposal",
            options: .foreground
        )

        let hotLeadCategory = UNNotificationCategory(
            identifier: "HOT_LEAD",
            actions: [viewLeadAction, generateProposalAction],
            intentIdentifiers: []
        )

        // Register all categories
        center.setNotificationCategories([
            morningBriefCategory,
            followUpCategory,
            hotLeadCategory
        ])
    }
}
