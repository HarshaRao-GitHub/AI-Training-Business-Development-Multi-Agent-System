//
//  LeadsViewModel.swift
//  BD Assistant
//
//  ViewModel for leads list management
//

import Foundation

@MainActor
class LeadsViewModel: ObservableObject {
    @Published var leads: [Lead] = []
    @Published var isLoading = false
    @Published var error: String?

    private let leadService = LeadService.shared

    init() {
        // Initial load from cache
        leads = leadService.leads
    }

    func refresh() {
        Task {
            await refreshAsync()
        }
    }

    func refreshAsync() async {
        isLoading = true
        await leadService.fetchLeads()
        leads = leadService.leads
        error = leadService.error
        isLoading = false
    }

    func createLead(_ lead: Lead) async {
        if let created = await leadService.createLead(lead) {
            leads.insert(created, at: 0)
        }
        error = leadService.error
    }

    func deleteLead(id: String) async {
        if await leadService.deleteLead(id: id) {
            leads.removeAll { $0.id == id }
        }
        error = leadService.error
    }

    func syncChanges() {
        Task {
            await leadService.syncPendingChanges()
            await refreshAsync()
        }
    }
}
