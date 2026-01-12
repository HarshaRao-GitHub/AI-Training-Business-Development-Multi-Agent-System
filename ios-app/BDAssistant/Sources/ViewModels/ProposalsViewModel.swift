//
//  ProposalsViewModel.swift
//  BD Assistant
//
//  ViewModel for proposals management
//

import Foundation

@MainActor
class ProposalsViewModel: ObservableObject {
    @Published var proposals: [Proposal] = []
    @Published var isLoading = false
    @Published var error: String?

    private let proposalService = ProposalService.shared

    init() {
        proposals = proposalService.proposals
    }

    func refresh() {
        Task {
            await refreshAsync()
        }
    }

    func refreshAsync() async {
        isLoading = true
        await proposalService.fetchProposals()
        proposals = proposalService.proposals
        error = proposalService.error
        isLoading = false
    }
}
