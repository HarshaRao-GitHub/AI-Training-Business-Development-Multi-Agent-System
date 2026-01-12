//
//  DashboardViewModel.swift
//  BD Assistant
//
//  ViewModel for the main dashboard
//

import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var metrics: DashboardMetrics?
    @Published var agents: [AgentInfo] = []
    @Published var priorityLeads: [Lead] = []
    @Published var latestBrief: IntelligenceBrief?
    @Published var isLoading = false
    @Published var error: String?

    // Sheet states
    @Published var showQualifyLead = false
    @Published var showGenerateProposal = false
    @Published var showVoiceRecorder = false

    private let apiClient = APIClient.shared
    private let leadService = LeadService.shared
    private let researchService = ResearchService.shared

    init() {
        // Use sample data for initial display
        agents = AgentInfo.samples
    }

    func refresh() {
        Task {
            await refreshAsync()
        }
    }

    func refreshAsync() async {
        isLoading = true
        error = nil

        // Fetch all dashboard data in parallel
        async let metricsTask: () = fetchMetrics()
        async let agentsTask: () = fetchAgents()
        async let leadsTask: () = fetchPriorityLeads()
        async let briefsTask: () = fetchLatestBrief()

        _ = await [metricsTask, agentsTask, leadsTask, briefsTask]

        isLoading = false
    }

    private func fetchMetrics() async {
        do {
            metrics = try await apiClient.getDashboardMetrics()
        } catch {
            // Use sample data on error
            metrics = DashboardMetrics.sample
        }
    }

    private func fetchAgents() async {
        do {
            agents = try await apiClient.getAgents()
        } catch {
            agents = AgentInfo.samples
        }
    }

    private func fetchPriorityLeads() async {
        await leadService.fetchLeads(score: .hot)
        priorityLeads = leadService.leads.prefix(5).map { $0 }
    }

    private func fetchLatestBrief() async {
        await researchService.fetchBriefs()
        latestBrief = researchService.briefs.first
    }

    func generateDailyBrief() {
        Task {
            isLoading = true
            latestBrief = await researchService.generateDailyBrief()
            isLoading = false
        }
    }
}
