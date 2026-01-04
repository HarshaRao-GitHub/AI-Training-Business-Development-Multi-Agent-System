//
//  ProposalsView.swift
//  BD Assistant
//
//  View for managing proposals
//

import SwiftUI

struct ProposalsView: View {
    @StateObject private var viewModel = ProposalsViewModel()
    @State private var selectedStatus: ProposalStatus?
    @State private var searchText = ""

    var filteredProposals: [Proposal] {
        var proposals = viewModel.proposals

        if let status = selectedStatus {
            proposals = proposals.filter { $0.status == status }
        }

        if !searchText.isEmpty {
            proposals = proposals.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }

        return proposals
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Status Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        StatusFilterChip(title: "All", isSelected: selectedStatus == nil) {
                            selectedStatus = nil
                        }

                        ForEach(ProposalStatus.allCases, id: \.self) { status in
                            StatusFilterChip(
                                title: status.displayName,
                                isSelected: selectedStatus == status
                            ) {
                                selectedStatus = status
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                Divider()

                // Proposals List
                if viewModel.isLoading && viewModel.proposals.isEmpty {
                    Spacer()
                    ProgressView("Loading proposals...")
                    Spacer()
                } else if filteredProposals.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        "No Proposals",
                        systemImage: "doc.text",
                        description: Text("Generate proposals from the Leads tab")
                    )
                    Spacer()
                } else {
                    List(filteredProposals) { proposal in
                        NavigationLink(destination: ProposalDetailView(proposal: proposal)) {
                            ProposalListRow(proposal: proposal)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Proposals")
            .searchable(text: $searchText, prompt: "Search proposals...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { viewModel.refresh() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                await viewModel.refreshAsync()
            }
            .onAppear {
                viewModel.refresh()
            }
        }
    }
}

// MARK: - Status Filter Chip
struct StatusFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
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

// MARK: - Proposal List Row
struct ProposalListRow: View {
    let proposal: Proposal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(proposal.title)
                    .font(.headline)
                    .lineLimit(1)

                Spacer()

                Image(systemName: proposal.status.iconName)
                    .foregroundStyle(statusColor)
            }

            if let summary = proposal.executiveSummary {
                Text(summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack {
                Label(proposal.status.displayName, systemImage: "circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if let pricing = proposal.pricing, let price = pricing.finalPrice {
                    Text(formatCurrency(price))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                }
            }

            HStack {
                Text("v\(proposal.version)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                if let days = proposal.daysUntilExpiry {
                    Text("•")
                        .foregroundStyle(.tertiary)

                    if days > 0 {
                        Text("Expires in \(days) days")
                            .font(.caption2)
                            .foregroundStyle(days <= 7 ? .orange : .tertiary)
                    } else {
                        Text("Expired")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }

                Spacer()

                Text(proposal.updatedAt.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch proposal.status {
        case .draft: return .gray
        case .pending: return .orange
        case .sent: return .blue
        case .viewed: return .purple
        case .accepted: return .green
        case .rejected: return .red
        case .expired: return .gray
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Proposal Detail View
struct ProposalDetailView: View {
    @StateObject private var proposalService = ProposalService.shared
    @State var proposal: Proposal
    @State private var showingSendConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Status Header
                statusHeader

                // Executive Summary
                if let summary = proposal.executiveSummary {
                    summarySection(summary)
                }

                // Training Modules
                if let modules = proposal.trainingModules, !modules.isEmpty {
                    modulesSection(modules)
                }

                // Delivery & Timeline
                deliverySection

                // Pricing
                if let pricing = proposal.pricing {
                    pricingSection(pricing)
                }

                // Actions
                actionsSection
            }
            .padding()
        }
        .navigationTitle("Proposal")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Send Proposal", isPresented: $showingSendConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Send") { sendProposal() }
        } message: {
            Text("Send this proposal to the client?")
        }
    }

    private var statusHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: proposal.status.iconName)
                    .font(.title)
                    .foregroundStyle(statusColor)

                VStack(alignment: .leading) {
                    Text(proposal.status.displayName)
                        .font(.headline)
                    Text("Version \(proposal.version)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let pricing = proposal.pricing, let price = pricing.finalPrice {
                    Text(formatCurrency(price))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                }
            }

            if let days = proposal.daysUntilExpiry {
                HStack {
                    if days > 0 {
                        Image(systemName: "clock")
                        Text("Expires in \(days) days")
                    } else {
                        Image(systemName: "exclamationmark.triangle")
                        Text("Expired")
                    }
                }
                .font(.caption)
                .foregroundStyle(days > 7 ? .secondary : .orange)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func summarySection(_ summary: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Executive Summary", systemImage: "doc.text")
                .font(.headline)

            Text(summary)
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
        }
    }

    private func modulesSection(_ modules: [TrainingModule]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Training Modules", systemImage: "book.fill")
                .font(.headline)

            ForEach(modules) { module in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(module.name)
                            .fontWeight(.medium)
                        Spacer()
                        if let duration = module.duration {
                            Text(duration)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.tertiarySystemFill))
                                .clipShape(Capsule())
                        }
                    }

                    if let description = module.description {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let format = module.format {
                        Label(format, systemImage: "display")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }

    private var deliverySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Delivery", systemImage: "shippingbox")
                .font(.headline)

            HStack(spacing: 16) {
                if let format = proposal.deliveryFormat {
                    VStack {
                        Image(systemName: "display")
                            .font(.title2)
                        Text(format)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }

                if let timeline = proposal.timeline {
                    VStack {
                        Image(systemName: "calendar")
                            .font(.title2)
                        Text(timeline)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
        }
    }

    private func pricingSection(_ pricing: ProposalPricing) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Pricing", systemImage: "dollarsign.circle")
                .font(.headline)

            VStack(spacing: 8) {
                if let basePrice = pricing.basePrice {
                    HStack {
                        Text("Base Price")
                        Spacer()
                        Text(formatCurrency(basePrice))
                    }
                    .font(.subheadline)
                }

                if let discount = pricing.discount, discount > 0 {
                    HStack {
                        Text("Discount")
                        Spacer()
                        Text("-\(Int(discount))%")
                            .foregroundStyle(.green)
                    }
                    .font(.subheadline)
                }

                Divider()

                if let finalPrice = pricing.finalPrice {
                    HStack {
                        Text("Total")
                            .fontWeight(.bold)
                        Spacer()
                        Text(formatCurrency(finalPrice))
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    }
                }

                if let terms = pricing.paymentTerms {
                    Text(terms)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            if proposal.status == .draft || proposal.status == .pending {
                Button(action: { showingSendConfirm = true }) {
                    Label("Send Proposal", systemImage: "paperplane.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
            }

            HStack(spacing: 12) {
                Button(action: {}) {
                    Label("Edit", systemImage: "pencil")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }

                Button(action: {}) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }
            }
        }
    }

    private var statusColor: Color {
        switch proposal.status {
        case .draft: return .gray
        case .pending: return .orange
        case .sent: return .blue
        case .viewed: return .purple
        case .accepted: return .green
        case .rejected: return .red
        case .expired: return .gray
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }

    private func sendProposal() {
        Task {
            if let sent = await proposalService.sendProposal(id: proposal.id) {
                proposal = sent
            }
        }
    }
}

#Preview {
    ProposalsView()
}
