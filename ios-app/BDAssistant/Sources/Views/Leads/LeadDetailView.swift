//
//  LeadDetailView.swift
//  BD Assistant
//
//  Detailed view for a single lead
//

import SwiftUI

struct LeadDetailView: View {
    @StateObject private var leadService = LeadService.shared
    @StateObject private var proposalService = ProposalService.shared
    @Environment(\.dismiss) private var dismiss

    @State var lead: Lead
    @State private var showingEditSheet = false
    @State private var showingProposalSheet = false
    @State private var showingEnrichConfirm = false
    @State private var isEnriching = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                headerCard

                // Quick Actions
                quickActionsRow

                // Contact Information
                if lead.contactName != nil || lead.contactEmail != nil {
                    contactSection
                }

                // Qualification Details
                if lead.qualificationScore != nil {
                    qualificationSection
                }

                // AI Insights
                if let signals = lead.aiAdoptionSignals, !signals.isEmpty {
                    aiSignalsSection(signals)
                }

                // Training Needs
                if let needs = lead.trainingNeeds, !needs.isEmpty {
                    trainingNeedsSection(needs)
                }

                // Decision Makers
                if let makers = lead.decisionMakers, !makers.isEmpty {
                    decisionMakersSection(makers)
                }

                // Notes
                if let notes = lead.notes {
                    notesSection(notes)
                }

                // Next Action
                if let nextAction = lead.nextAction {
                    nextActionSection(nextAction)
                }

                // Related Proposals
                proposalsSection
            }
            .padding()
        }
        .navigationTitle(lead.companyName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Edit Lead", systemImage: "pencil") {
                        showingEditSheet = true
                    }

                    Button("Enrich with AI", systemImage: "sparkles") {
                        showingEnrichConfirm = true
                    }

                    Button("Generate Proposal", systemImage: "doc.badge.plus") {
                        showingProposalSheet = true
                    }

                    Divider()

                    Menu("Change Status") {
                        ForEach(LeadStatus.allCases, id: \.self) { status in
                            Button(status.displayName) {
                                updateStatus(to: status)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingProposalSheet) {
            GenerateProposalSheet(lead: lead)
        }
        .alert("Enrich Lead", isPresented: $showingEnrichConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Enrich") { enrichLead() }
        } message: {
            Text("Use AI to gather additional information about \(lead.companyName)?")
        }
    }

    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lead.industry)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let size = lead.companySize {
                        Text("\(size) employees")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(lead.score.emoji)
                        Text(lead.score.displayName)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(scoreColor)

                    if let score = lead.qualificationScore {
                        Text("Score: \(score)/100")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Divider()

            HStack {
                Label(lead.status.displayName, systemImage: "circle.fill")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())

                Spacer()

                if let value = lead.estimatedValue {
                    Text(formatCurrency(value))
                        .font(.headline)
                        .foregroundStyle(.green)
                }
            }

            if let website = lead.website {
                Link(destination: URL(string: website) ?? URL(string: "https://example.com")!) {
                    Label(website.replacingOccurrences(of: "https://", with: ""), systemImage: "globe")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Quick Actions
    private var quickActionsRow: some View {
        HStack(spacing: 12) {
            if let email = lead.contactEmail {
                ActionButton(title: "Email", icon: "envelope.fill", color: .blue) {
                    if let url = URL(string: "mailto:\(email)") {
                        UIApplication.shared.open(url)
                    }
                }
            }

            if let phone = lead.contactPhone {
                ActionButton(title: "Call", icon: "phone.fill", color: .green) {
                    if let url = URL(string: "tel:\(phone)") {
                        UIApplication.shared.open(url)
                    }
                }
            }

            ActionButton(title: "Proposal", icon: "doc.text.fill", color: .purple) {
                showingProposalSheet = true
            }

            if isEnriching {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                ActionButton(title: "Enrich", icon: "sparkles", color: .orange) {
                    showingEnrichConfirm = true
                }
            }
        }
    }

    // MARK: - Sections
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Primary Contact", icon: "person.fill")

            VStack(alignment: .leading, spacing: 8) {
                if let name = lead.contactName {
                    HStack {
                        Text(name)
                            .fontWeight(.medium)
                        if let title = lead.contactTitle {
                            Text("• \(title)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let email = lead.contactEmail {
                    Label(email, systemImage: "envelope")
                        .font(.subheadline)
                }

                if let phone = lead.contactPhone {
                    Label(phone, systemImage: "phone")
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }

    private var qualificationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Qualification", icon: "checkmark.seal.fill")

            VStack(alignment: .leading, spacing: 12) {
                // Score bar
                if let score = lead.qualificationScore {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Qualification Score")
                                .font(.subheadline)
                            Spacer()
                            Text("\(score)/100")
                                .fontWeight(.bold)
                                .foregroundStyle(qualificationColor(score))
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.tertiarySystemFill))

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(qualificationColor(score))
                                    .frame(width: geo.size.width * CGFloat(score) / 100)
                            }
                        }
                        .frame(height: 8)
                    }
                }

                if let notes = lead.qualificationNotes {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }

    private func aiSignalsSection(_ signals: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "AI Adoption Signals", icon: "cpu")

            FlowLayout(spacing: 8) {
                ForEach(signals, id: \.self) { signal in
                    Text(signal)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }

    private func trainingNeedsSection(_ needs: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Training Needs", icon: "book.fill")

            VStack(alignment: .leading, spacing: 8) {
                ForEach(needs, id: \.self) { need in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text(need)
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }

    private func decisionMakersSection(_ makers: [DecisionMaker]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Decision Makers", icon: "person.2.fill")

            VStack(spacing: 8) {
                ForEach(makers, id: \.name) { maker in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(maker.name)
                                .fontWeight(.medium)
                            Text(maker.title)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if let influence = maker.influence {
                            Text(influence)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.tertiarySystemFill))
                                .clipShape(Capsule())
                        }
                    }
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }

    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Notes", icon: "note.text")

            Text(notes)
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
        }
    }

    private func nextActionSection(_ action: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Next Action", icon: "arrow.right.circle.fill")

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(action)
                        .fontWeight(.medium)

                    if let date = lead.nextActionDate {
                        Text(date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Button("Complete") {
                    // Mark action complete
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }

    private var proposalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Proposals", icon: "doc.text.fill")

            let proposals = proposalService.proposalsForLead(lead.id)

            if proposals.isEmpty {
                Button(action: { showingProposalSheet = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Generate First Proposal")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            } else {
                ForEach(proposals) { proposal in
                    ProposalRow(proposal: proposal)
                }
            }
        }
    }

    // MARK: - Helpers
    private var scoreColor: Color {
        switch lead.score {
        case .hot: return .red
        case .warm: return .orange
        case .cold: return .blue
        }
    }

    private func qualificationColor(_ score: Int) -> Color {
        if score >= 70 { return .green }
        if score >= 40 { return .orange }
        return .red
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }

    private func updateStatus(to status: LeadStatus) {
        Task {
            if let updated = await leadService.updateLeadStatus(lead, to: status) {
                lead = updated
            }
        }
    }

    private func enrichLead() {
        isEnriching = true
        Task {
            if let enriched = await leadService.enrichLead(id: lead.id) {
                lead = enriched
            }
            isEnriching = false
        }
    }
}

// MARK: - Supporting Views
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .foregroundStyle(color)
            .cornerRadius(12)
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.headline)
    }
}

struct ProposalRow: View {
    let proposal: Proposal

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(proposal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack {
                    Image(systemName: proposal.status.iconName)
                    Text(proposal.status.displayName)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if let price = proposal.pricing?.finalPrice {
                Text("$\(Int(price))")
                    .font(.subheadline)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layoutSizes(sizes, containerWidth: proposal.width ?? 0).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let positions = layoutSizes(sizes, containerWidth: bounds.width).positions

        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + positions[index].x, y: bounds.minY + positions[index].y), proposal: .unspecified)
        }
    }

    private func layoutSizes(_ sizes: [CGSize], containerWidth: CGFloat) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for size in sizes {
            if currentX + size.width > containerWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }

        return (CGSize(width: containerWidth, height: currentY + lineHeight), positions)
    }
}

// MARK: - Generate Proposal Sheet
struct GenerateProposalSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var proposalService = ProposalService.shared

    let lead: Lead

    @State private var budget = ""
    @State private var timeline = "4 weeks"
    @State private var deliveryPreference = "Hybrid"
    @State private var customRequirements = ""

    let timelineOptions = ["2 weeks", "4 weeks", "6 weeks", "8 weeks", "12 weeks"]
    let deliveryOptions = ["In-person", "Virtual", "Hybrid"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Training Details") {
                    if let needs = lead.trainingNeeds, !needs.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Identified Training Needs")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ForEach(needs, id: \.self) { need in
                                Text("• \(need)")
                                    .font(.subheadline)
                            }
                        }
                    }

                    TextField("Budget (optional)", text: $budget)
                        .keyboardType(.numberPad)

                    Picker("Timeline", selection: $timeline) {
                        ForEach(timelineOptions, id: \.self) { Text($0) }
                    }

                    Picker("Delivery", selection: $deliveryPreference) {
                        ForEach(deliveryOptions, id: \.self) { Text($0) }
                    }
                }

                Section("Custom Requirements") {
                    TextEditor(text: $customRequirements)
                        .frame(minHeight: 100)
                }

                Section {
                    Button(action: generate) {
                        if proposalService.isGenerating {
                            HStack {
                                ProgressView()
                                Text("Generating...")
                            }
                        } else {
                            Text("Generate Proposal with AI")
                        }
                    }
                    .disabled(proposalService.isGenerating)
                }
            }
            .navigationTitle("Generate Proposal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func generate() {
        Task {
            let budgetValue = Double(budget)
            _ = await proposalService.generateProposal(
                for: lead.id,
                trainingNeeds: lead.trainingNeeds,
                budget: budgetValue,
                timeline: timeline,
                deliveryPreference: deliveryPreference,
                customRequirements: customRequirements.isEmpty ? nil : customRequirements
            )
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        LeadDetailView(lead: Lead.sample)
    }
}
