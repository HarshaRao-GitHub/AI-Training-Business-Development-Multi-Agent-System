//
//  BDAssistantWidget.swift
//  BD Assistant Widget
//
//  Home screen widgets for quick access to BD metrics and leads
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct BDWidgetEntry: TimelineEntry {
    let date: Date
    let hotLeadsCount: Int
    let pipelineValue: Double
    let pendingProposals: Int
    let nextAction: String?
    let nextActionCompany: String?
    let winRate: Double
}

// MARK: - Widget Provider
struct BDWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> BDWidgetEntry {
        BDWidgetEntry(
            date: Date(),
            hotLeadsCount: 5,
            pipelineValue: 450000,
            pendingProposals: 3,
            nextAction: "Follow up call",
            nextActionCompany: "TechCorp",
            winRate: 0.32
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (BDWidgetEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BDWidgetEntry>) -> Void) {
        // In a real app, fetch from shared app group data
        let entry = BDWidgetEntry(
            date: Date(),
            hotLeadsCount: UserDefaults(suiteName: "group.com.bdassistant")?.integer(forKey: "hotLeadsCount") ?? 0,
            pipelineValue: UserDefaults(suiteName: "group.com.bdassistant")?.double(forKey: "pipelineValue") ?? 0,
            pendingProposals: UserDefaults(suiteName: "group.com.bdassistant")?.integer(forKey: "pendingProposals") ?? 0,
            nextAction: UserDefaults(suiteName: "group.com.bdassistant")?.string(forKey: "nextAction"),
            nextActionCompany: UserDefaults(suiteName: "group.com.bdassistant")?.string(forKey: "nextActionCompany"),
            winRate: UserDefaults(suiteName: "group.com.bdassistant")?.double(forKey: "winRate") ?? 0
        )

        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: BDWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.red)
                Text("\(entry.hotLeadsCount)")
                    .font(.title)
                    .fontWeight(.bold)
            }

            Text("Hot Leads")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            if let company = entry.nextActionCompany {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Next:")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Text(company)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: BDWidgetEntry

    var body: some View {
        HStack(spacing: 16) {
            // Hot Leads
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.red)
                    Text("\(entry.hotLeadsCount)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                Text("Hot Leads")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // Pipeline
            VStack(alignment: .leading, spacing: 4) {
                Text(formatCurrency(entry.pipelineValue))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
                Text("Pipeline")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // Proposals
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.pendingProposals)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.purple)
                Text("Pending")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private func formatCurrency(_ value: Double) -> String {
        if value >= 1_000_000 {
            return "$\(String(format: "%.1fM", value / 1_000_000))"
        } else if value >= 1_000 {
            return "$\(String(format: "%.0fK", value / 1_000))"
        }
        return "$\(Int(value))"
    }
}

// MARK: - Large Widget View
struct LargeWidgetView: View {
    let entry: BDWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text("BD Assistant")
                    .font(.headline)
                Spacer()
                Text(entry.date.formatted(.dateTime.hour().minute()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Metrics Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                WidgetMetricCell(
                    icon: "flame.fill",
                    iconColor: .red,
                    value: "\(entry.hotLeadsCount)",
                    label: "Hot Leads"
                )

                WidgetMetricCell(
                    icon: "dollarsign.circle.fill",
                    iconColor: .green,
                    value: formatCurrency(entry.pipelineValue),
                    label: "Pipeline"
                )

                WidgetMetricCell(
                    icon: "doc.text.fill",
                    iconColor: .purple,
                    value: "\(entry.pendingProposals)",
                    label: "Pending Proposals"
                )

                WidgetMetricCell(
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: .blue,
                    value: String(format: "%.0f%%", entry.winRate * 100),
                    label: "Win Rate"
                )
            }

            Divider()

            // Next Action
            if let action = entry.nextAction, let company = entry.nextActionCompany {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NEXT ACTION")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text(company)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(action)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private func formatCurrency(_ value: Double) -> String {
        if value >= 1_000_000 {
            return "$\(String(format: "%.1fM", value / 1_000_000))"
        } else if value >= 1_000 {
            return "$\(String(format: "%.0fK", value / 1_000))"
        }
        return "$\(Int(value))"
    }
}

// MARK: - Widget Metric Cell
struct WidgetMetricCell: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Main Widget
struct BDAssistantWidget: Widget {
    let kind: String = "BDAssistantWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BDWidgetProvider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("BD Assistant")
        .description("Quick access to your business development metrics")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: BDWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Hot Leads Widget
struct HotLeadsWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> HotLeadsEntry {
        HotLeadsEntry(date: Date(), leads: [
            WidgetLead(name: "TechCorp", industry: "Technology", score: 92),
            WidgetLead(name: "FinanceFlow", industry: "Finance", score: 85),
            WidgetLead(name: "HealthTech", industry: "Healthcare", score: 78)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (HotLeadsEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HotLeadsEntry>) -> Void) {
        let entry = placeholder(in: context)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900)))
        completion(timeline)
    }
}

struct WidgetLead: Identifiable {
    let id = UUID()
    let name: String
    let industry: String
    let score: Int
}

struct HotLeadsEntry: TimelineEntry {
    let date: Date
    let leads: [WidgetLead]
}

struct HotLeadsWidgetView: View {
    let entry: HotLeadsEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.red)
                Text("Hot Leads")
                    .font(.headline)
            }

            ForEach(entry.leads.prefix(3)) { lead in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(lead.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(lead.industry)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(lead.score)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct HotLeadsWidget: Widget {
    let kind = "HotLeadsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HotLeadsWidgetProvider()) { entry in
            HotLeadsWidgetView(entry: entry)
        }
        .configurationDisplayName("Hot Leads")
        .description("Your highest priority leads")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Widget Bundle
@main
struct BDAssistantWidgets: WidgetBundle {
    var body: some Widget {
        BDAssistantWidget()
        HotLeadsWidget()
    }
}

#Preview(as: .systemSmall) {
    BDAssistantWidget()
} timeline: {
    BDWidgetEntry(
        date: Date(),
        hotLeadsCount: 8,
        pipelineValue: 1250000,
        pendingProposals: 5,
        nextAction: "Discovery call",
        nextActionCompany: "TechCorp Industries",
        winRate: 0.32
    )
}

#Preview(as: .systemMedium) {
    BDAssistantWidget()
} timeline: {
    BDWidgetEntry(
        date: Date(),
        hotLeadsCount: 8,
        pipelineValue: 1250000,
        pendingProposals: 5,
        nextAction: "Discovery call",
        nextActionCompany: "TechCorp Industries",
        winRate: 0.32
    )
}

#Preview(as: .systemLarge) {
    BDAssistantWidget()
} timeline: {
    BDWidgetEntry(
        date: Date(),
        hotLeadsCount: 8,
        pipelineValue: 1250000,
        pendingProposals: 5,
        nextAction: "Discovery call",
        nextActionCompany: "TechCorp Industries",
        winRate: 0.32
    )
}
