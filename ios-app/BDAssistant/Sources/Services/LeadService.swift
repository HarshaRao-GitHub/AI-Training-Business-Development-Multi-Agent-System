//
//  LeadService.swift
//  BD Assistant
//
//  Lead management service with offline support
//

import Foundation
import Combine

@MainActor
class LeadService: ObservableObject {
    static let shared = LeadService()

    @Published var leads: [Lead] = []
    @Published var isLoading = false
    @Published var error: String?

    private let apiClient = APIClient.shared
    private let persistence = PersistenceController.shared
    private let networkMonitor = NetworkMonitor.shared

    private init() {
        // Load cached leads on init
        loadCachedLeads()
    }

    // MARK: - Fetch Leads
    func fetchLeads(status: LeadStatus? = nil, score: LeadScore? = nil, forceRefresh: Bool = false) async {
        isLoading = true
        error = nil

        // Return cached data if offline
        if !networkMonitor.isConnected {
            loadCachedLeads()
            isLoading = false
            return
        }

        do {
            let fetchedLeads = try await apiClient.getLeads(status: status, score: score)
            self.leads = fetchedLeads

            // Cache leads for offline use
            for lead in fetchedLeads {
                persistence.cacheLead(lead)
            }
        } catch {
            self.error = error.localizedDescription
            // Fall back to cached data
            loadCachedLeads()
        }

        isLoading = false
    }

    // MARK: - Get Single Lead
    func getLead(id: String) async -> Lead? {
        // Check cache first
        if let cached = leads.first(where: { $0.id == id }) {
            return cached
        }

        guard networkMonitor.isConnected else {
            return nil
        }

        do {
            let lead = try await apiClient.getLead(id: id)
            persistence.cacheLead(lead)
            return lead
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }

    // MARK: - Qualify Lead
    func qualifyLead(companyName: String, industry: String?, website: String?) async -> LeadQualificationResponse? {
        guard networkMonitor.isConnected else {
            error = "Cannot qualify leads while offline"
            return nil
        }

        isLoading = true

        do {
            let request = LeadQualificationRequest(
                companyName: companyName,
                industry: industry,
                companySize: nil,
                website: website,
                additionalContext: nil
            )

            let response = try await apiClient.qualifyLead(request)
            isLoading = false
            return response
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            return nil
        }
    }

    // MARK: - Create Lead
    func createLead(_ lead: Lead) async -> Lead? {
        guard networkMonitor.isConnected else {
            // Queue for later sync
            persistence.cacheLead(lead)
            leads.insert(lead, at: 0)
            return lead
        }

        do {
            let created = try await apiClient.createLead(lead)
            persistence.cacheLead(created)
            leads.insert(created, at: 0)
            return created
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }

    // MARK: - Update Lead
    func updateLead(_ lead: Lead) async -> Lead? {
        guard networkMonitor.isConnected else {
            persistence.cacheLead(lead)
            if let index = leads.firstIndex(where: { $0.id == lead.id }) {
                leads[index] = lead
            }
            return lead
        }

        do {
            let updated = try await apiClient.updateLead(lead)
            persistence.cacheLead(updated)

            if let index = leads.firstIndex(where: { $0.id == lead.id }) {
                leads[index] = updated
            }

            return updated
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }

    // MARK: - Update Lead Status
    func updateLeadStatus(_ lead: Lead, to status: LeadStatus) async -> Lead? {
        var updatedLead = lead
        updatedLead.status = status

        return await updateLead(updatedLead)
    }

    // MARK: - Enrich Lead
    func enrichLead(id: String) async -> Lead? {
        guard networkMonitor.isConnected else {
            error = "Cannot enrich leads while offline"
            return nil
        }

        isLoading = true

        do {
            let enriched = try await apiClient.enrichLead(id: id)
            persistence.cacheLead(enriched)

            if let index = leads.firstIndex(where: { $0.id == id }) {
                leads[index] = enriched
            }

            isLoading = false
            return enriched
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            return nil
        }
    }

    // MARK: - Delete Lead
    func deleteLead(id: String) async -> Bool {
        guard networkMonitor.isConnected else {
            error = "Cannot delete leads while offline"
            return false
        }

        do {
            try await apiClient.deleteLead(id: id)
            leads.removeAll { $0.id == id }
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }

    // MARK: - Filter Leads
    func filterLeads(by score: LeadScore) -> [Lead] {
        leads.filter { $0.score == score }
    }

    func filterLeads(by status: LeadStatus) -> [Lead] {
        leads.filter { $0.status == status }
    }

    func searchLeads(query: String) -> [Lead] {
        guard !query.isEmpty else { return leads }

        let lowercased = query.lowercased()
        return leads.filter {
            $0.companyName.lowercased().contains(lowercased) ||
            ($0.contactName?.lowercased().contains(lowercased) ?? false) ||
            $0.industry.lowercased().contains(lowercased)
        }
    }

    // MARK: - Private Methods
    private func loadCachedLeads() {
        leads = persistence.getCachedLeads()
    }

    // MARK: - Sync
    func syncPendingChanges() async {
        guard networkMonitor.isConnected else { return }

        let unsynced = persistence.getUnsyncedLeads()

        for cached in unsynced {
            guard let id = cached.id else { continue }

            // Attempt to sync
            // In a real app, you'd determine if this is a create or update
            persistence.markLeadAsSynced(id: id)
        }
    }
}
