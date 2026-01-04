//
//  ProposalService.swift
//  BD Assistant
//
//  Proposal management service
//

import Foundation

@MainActor
class ProposalService: ObservableObject {
    static let shared = ProposalService()

    @Published var proposals: [Proposal] = []
    @Published var isLoading = false
    @Published var isGenerating = false
    @Published var error: String?

    private let apiClient = APIClient.shared
    private let persistence = PersistenceController.shared
    private let networkMonitor = NetworkMonitor.shared

    private init() {}

    // MARK: - Fetch Proposals
    func fetchProposals(leadId: String? = nil, status: ProposalStatus? = nil) async {
        isLoading = true
        error = nil

        guard networkMonitor.isConnected else {
            isLoading = false
            error = "Offline - showing cached data"
            return
        }

        do {
            let fetched = try await apiClient.getProposals(leadId: leadId, status: status)
            self.proposals = fetched

            // Cache proposals
            for proposal in fetched {
                persistence.cacheProposal(proposal)
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Get Single Proposal
    func getProposal(id: String) async -> Proposal? {
        if let cached = proposals.first(where: { $0.id == id }) {
            return cached
        }

        guard networkMonitor.isConnected else {
            return nil
        }

        do {
            let proposal = try await apiClient.getProposal(id: id)
            persistence.cacheProposal(proposal)
            return proposal
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }

    // MARK: - Generate Proposal
    func generateProposal(
        for leadId: String,
        trainingNeeds: [String]?,
        budget: Double?,
        timeline: String?,
        deliveryPreference: String?,
        customRequirements: String?
    ) async -> Proposal? {
        guard networkMonitor.isConnected else {
            error = "Cannot generate proposals while offline"
            return nil
        }

        isGenerating = true
        error = nil

        do {
            let request = ProposalGenerationRequest(
                leadId: leadId,
                trainingNeeds: trainingNeeds,
                budget: budget,
                timeline: timeline,
                deliveryPreference: deliveryPreference,
                customRequirements: customRequirements
            )

            let proposal = try await apiClient.generateProposal(request)
            persistence.cacheProposal(proposal)
            proposals.insert(proposal, at: 0)

            isGenerating = false
            return proposal
        } catch {
            self.error = error.localizedDescription
            isGenerating = false
            return nil
        }
    }

    // MARK: - Update Proposal
    func updateProposal(_ proposal: Proposal) async -> Proposal? {
        guard networkMonitor.isConnected else {
            persistence.cacheProposal(proposal)
            if let index = proposals.firstIndex(where: { $0.id == proposal.id }) {
                proposals[index] = proposal
            }
            return proposal
        }

        do {
            let updated = try await apiClient.updateProposal(proposal)
            persistence.cacheProposal(updated)

            if let index = proposals.firstIndex(where: { $0.id == proposal.id }) {
                proposals[index] = updated
            }

            return updated
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }

    // MARK: - Send Proposal
    func sendProposal(id: String) async -> Proposal? {
        guard networkMonitor.isConnected else {
            error = "Cannot send proposals while offline"
            return nil
        }

        isLoading = true

        do {
            let sent = try await apiClient.sendProposal(id: id)
            persistence.cacheProposal(sent)

            if let index = proposals.firstIndex(where: { $0.id == id }) {
                proposals[index] = sent
            }

            isLoading = false
            return sent
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            return nil
        }
    }

    // MARK: - Filter Proposals
    func proposalsForLead(_ leadId: String) -> [Proposal] {
        proposals.filter { $0.leadId == leadId }
    }

    func activeProposals() -> [Proposal] {
        proposals.filter { $0.isActive }
    }

    func pendingProposals() -> [Proposal] {
        proposals.filter { $0.status == .pending || $0.status == .draft }
    }
}
