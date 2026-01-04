//
//  DashboardView.swift
//  BD Assistant
//
//  Main dashboard showing key metrics and agent status
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Sync Status
                    if let lastSync = appState.lastSyncDate {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Last synced: \(lastSync.formatted(.relative(presentation: .named)))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }

                    // Key Metrics
                    metricsSection

                    // Quick Actions
                    quickActionsSection

                    // Agent Status
                    agentStatusSection

                    // Today's Priorities
                    if !viewModel.priorityLeads.isEmpty {
                        priorityLeadsSection
                    }

                    // Morning Brief Preview
                    if let brief = viewModel.latestBrief {
                        briefPreviewSection(brief)
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Dashboard")
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

    // MARK: - Metrics Section
    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pipeline Overview")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MetricCard(
                    title: "Total Leads",
                    value: "\(viewModel.metrics?.totalLeads ?? 0)",
                    icon: "person.3",
                    color: .blue
                )

                MetricCard(
                    title: "Hot Leads",
                    value: "\(viewModel.metrics?.hotLeads ?? 0)",
                    icon: "flame",
                    color: .red
                )

                MetricCard(
                    title: "Pipeline Value",
                    value: formatCurrency(viewModel.metrics?.pipelineValue ?? 0),
                    icon: "dollarsign.circle",
                    color: .green
                )

                MetricCard(
                    title: "Win Rate",
                    value: String(format: "%.0f%%", (viewModel.metrics?.winRate ?? 0) * 100),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickActionButton(
                        title: "Qualify Lead",
                        icon: "person.badge.plus",
                        color: .blue
                    ) {
                        viewModel.showQualifyLead = true
                    }

                    QuickActionButton(
                        title: "Generate Proposal",
                        icon: "doc.badge.plus",
                        color: .green
                    ) {
                        viewModel.showGenerateProposal = true
                    }

                    QuickActionButton(
                        title: "Daily Brief",
                        icon: "newspaper",
                        color: .orange
                    ) {
                        viewModel.generateDailyBrief()
                    }

                    QuickActionButton(
                        title: "Voice Note",
                        icon: "mic",
                        color: .red
                    ) {
                        viewModel.showVoiceRecorder = true
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $viewModel.showQualifyLead) {
            QuickQualifyView()
        }
        .sheet(isPresented: $viewModel.showVoiceRecorder) {
            VoiceRecorderView()
        }
    }

    // MARK: - Agent Status
    private var agentStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI Agents")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.metrics?.agentsOnline ?? 7)/7 online")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.agents) { agent in
                        AgentStatusCard(agent: agent)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Priority Leads
    private var priorityLeadsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Priorities")
                    .font(.headline)
                Spacer()
                NavigationLink("See All") {
                    LeadsListView()
                }
                .font(.caption)
            }
            .padding(.horizontal)

            ForEach(viewModel.priorityLeads.prefix(3)) { lead in
                NavigationLink(destination: LeadDetailView(lead: lead)) {
                    LeadCard(lead: lead)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Brief Preview
    private func briefPreviewSection(_ brief: IntelligenceBrief) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Latest Intelligence")
                    .font(.headline)

                if !brief.isRead {
                    Circle()
                        .fill(.blue)
                        .frame(width: 8, height: 8)
                }

                Spacer()

                NavigationLink("View All") {
                    IntelligenceBriefView()
                }
                .font(.caption)
            }
            .padding(.horizontal)

            NavigationLink(destination: BriefDetailView(brief: brief)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: brief.briefType.iconName)
                            .foregroundStyle(.blue)
                        Text(brief.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text(brief.createdAt.formatted(.relative(presentation: .named)))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Text(brief.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)

                    if !brief.recommendations.isEmpty {
                        HStack {
                            Image(systemName: "lightbulb")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text("\(brief.recommendations.count) recommendations")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
        }
    }

    // MARK: - Helpers
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0

        if value >= 1_000_000 {
            return "$\(String(format: "%.1fM", value / 1_000_000))"
        } else if value >= 1_000 {
            return "$\(String(format: "%.0fK", value / 1_000))"
        }

        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(width: 80, height: 80)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Quick Qualify View
struct QuickQualifyView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var leadService = LeadService.shared

    @State private var companyName = ""
    @State private var industry = ""
    @State private var website = ""
    @State private var isLoading = false
    @State private var result: LeadQualificationResponse?

    var body: some View {
        NavigationStack {
            Form {
                Section("Company Information") {
                    TextField("Company Name", text: $companyName)
                    TextField("Industry", text: $industry)
                    TextField("Website (optional)", text: $website)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }

                if let result = result {
                    Section("Qualification Result") {
                        HStack {
                            Text("Score")
                            Spacer()
                            Text("\(result.qualificationScore)/100")
                                .fontWeight(.bold)
                                .foregroundStyle(scoreColor(result.qualificationScore))
                        }

                        Text(result.recommendation)
                            .font(.caption)

                        if !result.trainingNeeds.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Training Needs")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                ForEach(result.trainingNeeds, id: \.self) { need in
                                    Text("• \(need)")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }

                Section {
                    Button(action: qualify) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text(result == nil ? "Qualify Lead" : "Qualify Again")
                        }
                    }
                    .disabled(companyName.isEmpty || isLoading)
                }
            }
            .navigationTitle("Quick Qualify")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func qualify() {
        isLoading = true
        Task {
            result = await leadService.qualifyLead(
                companyName: companyName,
                industry: industry.isEmpty ? nil : industry,
                website: website.isEmpty ? nil : website
            )
            isLoading = false
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 70 { return .green }
        if score >= 40 { return .orange }
        return .red
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppState())
}
