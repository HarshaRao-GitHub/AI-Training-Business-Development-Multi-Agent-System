//
//  IntelligenceBriefView.swift
//  BD Assistant
//
//  Intelligence briefs and market research view
//

import SwiftUI

struct IntelligenceBriefView: View {
    @StateObject private var researchService = ResearchService.shared
    @State private var selectedType: BriefType?
    @State private var showingResearchSheet = false

    var filteredBriefs: [IntelligenceBrief] {
        guard let type = selectedType else {
            return researchService.briefs
        }
        return researchService.briefsByType(type)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        TypeFilterChip(
                            title: "All",
                            icon: "tray.full",
                            isSelected: selectedType == nil,
                            badge: researchService.unreadCount
                        ) {
                            selectedType = nil
                        }

                        ForEach(BriefType.allCases, id: \.self) { type in
                            TypeFilterChip(
                                title: type.displayName,
                                icon: type.iconName,
                                isSelected: selectedType == type,
                                badge: 0
                            ) {
                                selectedType = type
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                Divider()

                // Briefs List
                if researchService.isLoading && researchService.briefs.isEmpty {
                    Spacer()
                    ProgressView("Loading intelligence...")
                    Spacer()
                } else if filteredBriefs.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        "No Briefs",
                        systemImage: "newspaper",
                        description: Text("Generate your first intelligence brief")
                    )
                    Spacer()
                } else {
                    List(filteredBriefs) { brief in
                        NavigationLink(destination: BriefDetailView(brief: brief)) {
                            BriefRow(brief: brief)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Intelligence")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Generate Daily Brief", systemImage: "sun.max") {
                            generateBrief()
                        }

                        Button("Market Research", systemImage: "magnifyingglass") {
                            showingResearchSheet = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { researchService.fetchBriefs() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                await researchService.fetchBriefs()
            }
            .sheet(isPresented: $showingResearchSheet) {
                MarketResearchSheet()
            }
            .onAppear {
                Task {
                    await researchService.fetchBriefs()
                }
            }
        }
    }

    private func generateBrief() {
        Task {
            _ = await researchService.generateDailyBrief()
        }
    }
}

// MARK: - Type Filter Chip
struct TypeFilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let badge: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)

                if badge > 0 {
                    Text("\(badge)")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .foregroundStyle(.white)
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

// MARK: - Brief Row
struct BriefRow: View {
    let brief: IntelligenceBrief

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: brief.briefType.iconName)
                    .foregroundStyle(.blue)

                Text(brief.title)
                    .font(.headline)
                    .lineLimit(1)

                if !brief.isRead {
                    Circle()
                        .fill(.blue)
                        .frame(width: 8, height: 8)
                }

                Spacer()

                PriorityBadge(priority: brief.priority)
            }

            Text(brief.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Label(brief.briefType.displayName, systemImage: "tag")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(brief.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            if !brief.insights.isEmpty {
                HStack {
                    Image(systemName: "lightbulb")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text("\(brief.insights.count) insights")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Priority Badge
struct PriorityBadge: View {
    let priority: BriefPriority

    var body: some View {
        Text(priority.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch priority {
        case .high: return .red.opacity(0.1)
        case .medium: return .orange.opacity(0.1)
        case .low: return .blue.opacity(0.1)
        }
    }

    private var foregroundColor: Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }
}

// MARK: - Brief Detail View
struct BriefDetailView: View {
    @StateObject private var researchService = ResearchService.shared
    let brief: IntelligenceBrief

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(brief.briefType.displayName, systemImage: brief.briefType.iconName)
                            .font(.subheadline)
                            .foregroundStyle(.blue)

                        Spacer()

                        PriorityBadge(priority: brief.priority)
                    }

                    Text(brief.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(brief.createdAt.formatted(date: .long, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("Summary")
                        .font(.headline)

                    Text(brief.summary)
                        .font(.body)
                }

                // Insights
                if !brief.insights.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Key Insights", systemImage: "lightbulb")
                            .font(.headline)

                        ForEach(brief.insights) { insight in
                            InsightCard(insight: insight)
                        }
                    }
                }

                // Recommendations
                if !brief.recommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Recommendations", systemImage: "checkmark.circle")
                            .font(.headline)

                        ForEach(Array(brief.recommendations.enumerated()), id: \.offset) { index, recommendation in
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)
                                Text(recommendation)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                    }
                }

                // Sources
                if let sources = brief.sources, !sources.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Sources", systemImage: "doc.text")
                            .font(.headline)

                        FlowLayout(spacing: 8) {
                            ForEach(sources, id: \.self) { source in
                                Text(source)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(.tertiarySystemFill))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !brief.isRead {
                Task {
                    await researchService.markAsRead(id: brief.id)
                }
            }
        }
    }
}

// MARK: - Insight Card
struct InsightCard: View {
    let insight: Insight

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                if let confidence = insight.confidence {
                    Text("\(Int(confidence * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(insight.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let actions = insight.actionItems, !actions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Action Items:")
                        .font(.caption2)
                        .fontWeight(.medium)

                    ForEach(actions, id: \.self) { action in
                        HStack(alignment: .top, spacing: 4) {
                            Image(systemName: "arrow.right")
                                .font(.caption2)
                                .foregroundStyle(.blue)
                            Text(action)
                                .font(.caption2)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Market Research Sheet
struct MarketResearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var researchService = ResearchService.shared

    @State private var industry = ""
    @State private var region = ""
    @State private var topics = ""
    @State private var result: MarketResearchResponse?

    var body: some View {
        NavigationStack {
            Form {
                Section("Research Parameters") {
                    TextField("Industry *", text: $industry)
                    TextField("Region (optional)", text: $region)
                    TextField("Topics (comma-separated)", text: $topics)
                }

                if let result = result {
                    Section("Research Results") {
                        if let size = result.marketSize {
                            HStack {
                                Text("Market Size")
                                Spacer()
                                Text(size)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if let growth = result.growthRate {
                            HStack {
                                Text("Growth Rate")
                                Spacer()
                                Text(growth)
                                    .foregroundStyle(.green)
                            }
                        }

                        if let adoption = result.aiAdoptionRate {
                            HStack {
                                Text("AI Adoption")
                                Spacer()
                                Text(adoption)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }

                    if !result.keyTrends.isEmpty {
                        Section("Key Trends") {
                            ForEach(result.keyTrends, id: \.self) { trend in
                                Text("• \(trend)")
                                    .font(.subheadline)
                            }
                        }
                    }

                    if !result.opportunities.isEmpty {
                        Section("Opportunities") {
                            ForEach(result.opportunities, id: \.self) { opp in
                                Text("• \(opp)")
                                    .font(.subheadline)
                            }
                        }
                    }

                    if !result.recommendations.isEmpty {
                        Section("Recommendations") {
                            ForEach(result.recommendations, id: \.self) { rec in
                                Text("• \(rec)")
                                    .font(.subheadline)
                            }
                        }
                    }
                }

                Section {
                    Button(action: conductResearch) {
                        if researchService.isLoading {
                            HStack {
                                ProgressView()
                                Text("Researching...")
                            }
                        } else {
                            Text(result == nil ? "Conduct Research" : "Research Again")
                        }
                    }
                    .disabled(industry.isEmpty || researchService.isLoading)
                }
            }
            .navigationTitle("Market Research")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func conductResearch() {
        let topicsList = topics.isEmpty ? nil : topics.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        Task {
            result = await researchService.conductMarketResearch(
                industry: industry,
                region: region.isEmpty ? nil : region,
                topics: topicsList
            )
        }
    }
}

#Preview {
    IntelligenceBriefView()
}
