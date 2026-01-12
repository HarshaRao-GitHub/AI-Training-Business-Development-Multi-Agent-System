//
//  BDAssistantWatchApp.swift
//  BD Assistant Watch
//
//  Apple Watch companion app for quick access to BD metrics
//

import SwiftUI
import WatchKit

@main
struct BDAssistantWatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @State private var metrics = WatchMetrics.sample
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Quick Metrics
                    metricsSection

                    // Hot Leads
                    hotLeadsSection

                    // Next Action
                    nextActionSection
                }
                .padding(.horizontal, 8)
            }
            .navigationTitle("BD Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: refresh) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }

    private var metricsSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                WatchMetricCard(
                    icon: "flame.fill",
                    value: "\(metrics.hotLeads)",
                    label: "Hot",
                    color: .red
                )

                WatchMetricCard(
                    icon: "person.3.fill",
                    value: "\(metrics.totalLeads)",
                    label: "Leads",
                    color: .blue
                )
            }

            HStack(spacing: 8) {
                WatchMetricCard(
                    icon: "doc.text.fill",
                    value: "\(metrics.pendingProposals)",
                    label: "Proposals",
                    color: .purple
                )

                WatchMetricCard(
                    icon: "chart.line.uptrend.xyaxis",
                    value: "\(Int(metrics.winRate * 100))%",
                    label: "Win Rate",
                    color: .green
                )
            }
        }
    }

    private var hotLeadsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Hot Leads", systemImage: "flame.fill")
                .font(.caption)
                .foregroundStyle(.red)

            ForEach(metrics.topLeads, id: \.name) { lead in
                NavigationLink(destination: LeadDetailWatchView(lead: lead)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(lead.name)
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(lead.industry)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("\(lead.score)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(8)
        .background(Color(.darkGray).opacity(0.3))
        .cornerRadius(10)
    }

    private var nextActionSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Next Action", systemImage: "arrow.right.circle.fill")
                .font(.caption)
                .foregroundStyle(.blue)

            if let action = metrics.nextAction {
                VStack(alignment: .leading, spacing: 2) {
                    Text(action.company)
                        .font(.caption)
                        .fontWeight(.medium)
                    Text(action.action)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("No pending actions")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(.darkGray).opacity(0.3))
        .cornerRadius(10)
    }

    private func refresh() {
        isLoading = true
        // Fetch from phone via WatchConnectivity
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
        }
    }
}

// MARK: - Watch Metric Card
struct WatchMetricCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Lead Detail Watch View
struct LeadDetailWatchView: View {
    let lead: WatchLead

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(lead.name)
                        .font(.headline)

                    Text(lead.industry)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Score
                HStack {
                    Text("Score")
                        .font(.caption)
                    Spacer()
                    Text("\(lead.score)/100")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(scoreColor)
                }

                // Contact
                if let contact = lead.contactName {
                    HStack {
                        Text("Contact")
                            .font(.caption)
                        Spacer()
                        Text(contact)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                // Quick Actions
                VStack(spacing: 8) {
                    Button(action: {}) {
                        Label("Call", systemImage: "phone.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    Button(action: {}) {
                        Label("Email", systemImage: "envelope.fill")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal, 8)
        }
        .navigationTitle("Lead")
    }

    private var scoreColor: Color {
        if lead.score >= 70 { return .green }
        if lead.score >= 40 { return .orange }
        return .red
    }
}

// MARK: - Watch Models
struct WatchMetrics {
    let hotLeads: Int
    let totalLeads: Int
    let pendingProposals: Int
    let winRate: Double
    let topLeads: [WatchLead]
    let nextAction: WatchAction?

    static var sample: WatchMetrics {
        WatchMetrics(
            hotLeads: 8,
            totalLeads: 127,
            pendingProposals: 5,
            winRate: 0.32,
            topLeads: [
                WatchLead(name: "TechCorp", industry: "Technology", score: 92, contactName: "Jane Smith"),
                WatchLead(name: "FinanceFlow", industry: "Finance", score: 85, contactName: "Robert Chen"),
                WatchLead(name: "HealthTech", industry: "Healthcare", score: 78, contactName: nil)
            ],
            nextAction: WatchAction(company: "TechCorp", action: "Discovery call at 2pm")
        )
    }
}

struct WatchLead: Identifiable {
    let id = UUID()
    let name: String
    let industry: String
    let score: Int
    let contactName: String?
}

struct WatchAction {
    let company: String
    let action: String
}

// MARK: - Complications
struct BDComplicationView: View {
    var body: some View {
        VStack {
            Image(systemName: "flame.fill")
                .foregroundStyle(.red)
            Text("8")
                .font(.title3)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    ContentView()
}
