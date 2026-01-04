//
//  ResearchService.swift
//  BD Assistant
//
//  Research and intelligence service
//

import Foundation

@MainActor
class ResearchService: ObservableObject {
    static let shared = ResearchService()

    @Published var briefs: [IntelligenceBrief] = []
    @Published var isLoading = false
    @Published var isGenerating = false
    @Published var error: String?

    private let apiClient = APIClient.shared
    private let persistence = PersistenceController.shared
    private let networkMonitor = NetworkMonitor.shared

    private init() {}

    // MARK: - Fetch Briefs
    func fetchBriefs(type: BriefType? = nil, unreadOnly: Bool = false) async {
        isLoading = true
        error = nil

        guard networkMonitor.isConnected else {
            isLoading = false
            error = "Offline - showing cached data"
            return
        }

        do {
            let fetched = try await apiClient.getIntelligenceBriefs(type: type, unreadOnly: unreadOnly)
            self.briefs = fetched

            // Cache briefs
            for brief in fetched {
                persistence.cacheBrief(brief)
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Generate Daily Brief
    func generateDailyBrief() async -> IntelligenceBrief? {
        guard networkMonitor.isConnected else {
            error = "Cannot generate briefs while offline"
            return nil
        }

        isGenerating = true
        error = nil

        do {
            let brief = try await apiClient.generateDailyBrief()
            persistence.cacheBrief(brief)
            briefs.insert(brief, at: 0)

            isGenerating = false
            return brief
        } catch {
            self.error = error.localizedDescription
            isGenerating = false
            return nil
        }
    }

    // MARK: - Mark as Read
    func markAsRead(id: String) async {
        guard networkMonitor.isConnected else { return }

        do {
            try await apiClient.markBriefAsRead(id: id)

            if let index = briefs.firstIndex(where: { $0.id == id }) {
                // Create updated brief with isRead = true
                var updated = briefs[index]
                // Note: In a real app, you'd need to make IntelligenceBrief mutable
                // or create a new instance
                briefs[index] = IntelligenceBrief(
                    id: updated.id,
                    title: updated.title,
                    summary: updated.summary,
                    briefType: updated.briefType,
                    priority: updated.priority,
                    insights: updated.insights,
                    recommendations: updated.recommendations,
                    sources: updated.sources,
                    relatedLeads: updated.relatedLeads,
                    isRead: true,
                    createdAt: updated.createdAt
                )
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Conduct Research
    func conductMarketResearch(industry: String, region: String? = nil, topics: [String]? = nil) async -> MarketResearchResponse? {
        guard networkMonitor.isConnected else {
            error = "Cannot conduct research while offline"
            return nil
        }

        isLoading = true
        error = nil

        do {
            let request = MarketResearchRequest(
                industry: industry,
                region: region,
                topics: topics,
                depth: "detailed"
            )

            let response = try await apiClient.conductMarketResearch(request)
            isLoading = false
            return response
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            return nil
        }
    }

    // MARK: - Filters
    var unreadBriefs: [IntelligenceBrief] {
        briefs.filter { !$0.isRead }
    }

    var unreadCount: Int {
        unreadBriefs.count
    }

    func briefsByType(_ type: BriefType) -> [IntelligenceBrief] {
        briefs.filter { $0.briefType == type }
    }

    func highPriorityBriefs() -> [IntelligenceBrief] {
        briefs.filter { $0.priority == .high }
    }
}
