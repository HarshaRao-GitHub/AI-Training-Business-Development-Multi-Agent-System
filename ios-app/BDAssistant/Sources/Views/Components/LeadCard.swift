//
//  LeadCard.swift
//  BD Assistant
//
//  Compact lead card for dashboard display
//

import SwiftUI

struct LeadCard: View {
    let lead: Lead

    var body: some View {
        HStack(spacing: 12) {
            // Score indicator
            VStack {
                Text(lead.score.emoji)
                    .font(.title2)

                if let score = lead.qualificationScore {
                    Text("\(score)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(scoreColor)
                }
            }
            .frame(width: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(lead.companyName)
                    .font(.headline)
                    .lineLimit(1)

                HStack {
                    Text(lead.industry)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let contact = lead.contactName {
                        Text("•")
                            .foregroundStyle(.tertiary)
                        Text(contact)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if let nextAction = lead.nextAction {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right.circle")
                            .font(.caption2)
                        Text(nextAction)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                    .foregroundStyle(.blue)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(lead.status.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.1))
                    .foregroundStyle(statusColor)
                    .clipShape(Capsule())

                if let value = lead.estimatedValue {
                    Text(formatCurrency(value))
                        .font(.caption)
                        .foregroundStyle(.green)
                }

                if let date = lead.nextActionDate {
                    Text(date.formatted(.dateTime.month(.abbreviated).day()))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var scoreColor: Color {
        switch lead.score {
        case .hot: return .red
        case .warm: return .orange
        case .cold: return .blue
        }
    }

    private var statusColor: Color {
        switch lead.status {
        case .new: return .blue
        case .qualified: return .green
        case .contacted: return .orange
        case .proposalSent: return .purple
        case .negotiation: return .yellow
        case .won: return .green
        case .lost: return .red
        case .inactive: return .gray
        }
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

#Preview {
    VStack {
        LeadCard(lead: Lead.sample)
        LeadCard(lead: Lead.samples[1])
        LeadCard(lead: Lead.samples[2])
    }
    .padding()
}
