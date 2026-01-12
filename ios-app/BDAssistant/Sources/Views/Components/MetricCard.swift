//
//  MetricCard.swift
//  BD Assistant
//
//  Card for displaying a single metric
//

import SwiftUI

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var trend: Double? = nil
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)

                Spacer()

                if let trend = trend {
                    TrendIndicator(value: trend)
                }
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Trend Indicator
struct TrendIndicator: View {
    let value: Double

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: value >= 0 ? "arrow.up.right" : "arrow.down.right")
                .font(.caption2)

            Text("\(abs(Int(value)))%")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundStyle(value >= 0 ? .green : .red)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background((value >= 0 ? Color.green : Color.red).opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Large Metric Card
struct LargeMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var progress: Double? = nil
    var details: [(String, String)]? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(title)
                    .font(.headline)

                Spacer()
            }

            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)

            if let progress = progress {
                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.tertiarySystemFill))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(color)
                                .frame(width: geo.size.width * progress)
                        }
                    }
                    .frame(height: 8)

                    Text("\(Int(progress * 100))% of target")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let details = details {
                Divider()

                ForEach(details, id: \.0) { detail in
                    HStack {
                        Text(detail.0)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(detail.1)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    VStack(spacing: 16) {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricCard(title: "Total Leads", value: "127", icon: "person.3", color: .blue)
            MetricCard(title: "Hot Leads", value: "12", icon: "flame", color: .red, trend: 15)
            MetricCard(title: "Pipeline", value: "$1.2M", icon: "dollarsign.circle", color: .green, trend: -5)
            MetricCard(title: "Win Rate", value: "32%", icon: "chart.line.uptrend.xyaxis", color: .purple)
        }

        LargeMetricCard(
            title: "Monthly Target",
            value: "$450K",
            icon: "target",
            color: .blue,
            progress: 0.65,
            details: [
                ("Won", "$293K"),
                ("Pipeline", "$892K"),
                ("Remaining", "$157K")
            ]
        )
    }
    .padding()
}
