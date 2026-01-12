//
//  LeadsListView.swift
//  BD Assistant
//
//  List view for managing leads
//

import SwiftUI

struct LeadsListView: View {
    @StateObject private var viewModel = LeadsViewModel()
    @State private var searchText = ""
    @State private var selectedFilter: LeadFilter = .all
    @State private var showingAddLead = false

    enum LeadFilter: String, CaseIterable {
        case all = "All"
        case hot = "Hot"
        case warm = "Warm"
        case cold = "Cold"
        case new = "New"
        case qualified = "Qualified"
    }

    var filteredLeads: [Lead] {
        var leads = viewModel.leads

        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .hot:
            leads = leads.filter { $0.score == .hot }
        case .warm:
            leads = leads.filter { $0.score == .warm }
        case .cold:
            leads = leads.filter { $0.score == .cold }
        case .new:
            leads = leads.filter { $0.status == .new }
        case .qualified:
            leads = leads.filter { $0.status == .qualified }
        }

        // Apply search
        if !searchText.isEmpty {
            leads = leads.filter {
                $0.companyName.localizedCaseInsensitiveContains(searchText) ||
                ($0.contactName?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                $0.industry.localizedCaseInsensitiveContains(searchText)
            }
        }

        return leads
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(LeadFilter.allCases, id: \.self) { filter in
                            FilterPill(
                                title: filter.rawValue,
                                isSelected: selectedFilter == filter,
                                count: countForFilter(filter)
                            ) {
                                withAnimation { selectedFilter = filter }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))

                Divider()

                // Lead List
                if viewModel.isLoading && viewModel.leads.isEmpty {
                    Spacer()
                    ProgressView("Loading leads...")
                    Spacer()
                } else if filteredLeads.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        "No Leads",
                        systemImage: "person.3",
                        description: Text(searchText.isEmpty ? "Add your first lead to get started" : "No leads match your search")
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(filteredLeads) { lead in
                            NavigationLink(destination: LeadDetailView(lead: lead)) {
                                LeadRow(lead: lead)
                            }
                        }
                        .onDelete(perform: deleteLead)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Leads")
            .searchable(text: $searchText, prompt: "Search leads...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddLead = true }) {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Refresh") { viewModel.refresh() }
                        Button("Sync Offline Changes") { viewModel.syncChanges() }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .refreshable {
                await viewModel.refreshAsync()
            }
            .sheet(isPresented: $showingAddLead) {
                AddLeadView { lead in
                    Task {
                        await viewModel.createLead(lead)
                    }
                }
            }
            .onAppear {
                viewModel.refresh()
            }
        }
    }

    private func countForFilter(_ filter: LeadFilter) -> Int {
        switch filter {
        case .all: return viewModel.leads.count
        case .hot: return viewModel.leads.filter { $0.score == .hot }.count
        case .warm: return viewModel.leads.filter { $0.score == .warm }.count
        case .cold: return viewModel.leads.filter { $0.score == .cold }.count
        case .new: return viewModel.leads.filter { $0.status == .new }.count
        case .qualified: return viewModel.leads.filter { $0.status == .qualified }.count
        }
    }

    private func deleteLead(at offsets: IndexSet) {
        for index in offsets {
            let lead = filteredLeads[index]
            Task {
                await viewModel.deleteLead(id: lead.id)
            }
        }
    }
}

// MARK: - Filter Pill
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.3) : Color(.tertiarySystemFill))
                        .clipShape(Capsule())
                }
            }
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Lead Row
struct LeadRow: View {
    let lead: Lead

    var body: some View {
        HStack(spacing: 12) {
            // Score indicator
            Circle()
                .fill(scoreColor)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(lead.companyName)
                        .font(.headline)

                    Spacer()

                    Text(lead.score.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(scoreColor.opacity(0.1))
                        .foregroundStyle(scoreColor)
                        .clipShape(Capsule())
                }

                HStack {
                    Text(lead.industry)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let contact = lead.contactName {
                        Text("•")
                            .foregroundStyle(.tertiary)
                        Text(contact)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Label(lead.status.displayName, systemImage: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    if let value = lead.estimatedValue {
                        Text(formatCurrency(value))
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var scoreColor: Color {
        switch lead.score {
        case .hot: return .red
        case .warm: return .orange
        case .cold: return .blue
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Add Lead View
struct AddLeadView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var companyName = ""
    @State private var industry = ""
    @State private var contactName = ""
    @State private var contactEmail = ""
    @State private var website = ""
    @State private var notes = ""

    let onCreate: (Lead) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Company") {
                    TextField("Company Name *", text: $companyName)
                    TextField("Industry *", text: $industry)
                    TextField("Website", text: $website)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }

                Section("Primary Contact") {
                    TextField("Name", text: $contactName)
                    TextField("Email", text: $contactEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Lead")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        let lead = Lead(
                            id: UUID().uuidString,
                            companyName: companyName,
                            industry: industry,
                            companySize: nil,
                            website: website.isEmpty ? nil : website,
                            contactName: contactName.isEmpty ? nil : contactName,
                            contactEmail: contactEmail.isEmpty ? nil : contactEmail,
                            contactPhone: nil,
                            contactTitle: nil,
                            status: .new,
                            score: .cold,
                            qualificationScore: nil,
                            qualificationNotes: nil,
                            source: "Mobile App",
                            estimatedValue: nil,
                            aiAdoptionSignals: nil,
                            trainingNeeds: nil,
                            decisionMakers: nil,
                            notes: notes.isEmpty ? nil : notes,
                            nextAction: nil,
                            nextActionDate: nil,
                            createdAt: Date(),
                            updatedAt: Date()
                        )
                        onCreate(lead)
                        dismiss()
                    }
                    .disabled(companyName.isEmpty || industry.isEmpty)
                }
            }
        }
    }
}

#Preview {
    LeadsListView()
}
