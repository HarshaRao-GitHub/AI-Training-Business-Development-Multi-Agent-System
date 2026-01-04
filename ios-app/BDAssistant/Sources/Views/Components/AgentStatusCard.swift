//
//  AgentStatusCard.swift
//  BD Assistant
//
//  Card showing individual agent status
//

import SwiftUI

struct AgentStatusCard: View {
    let agent: AgentInfo

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(agent.isOnline ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)

                Image(systemName: agent.iconName)
                    .font(.title2)
                    .foregroundStyle(agent.isOnline ? .green : .gray)
            }

            Text(agent.displayName)
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 70)

            Circle()
                .fill(agent.isOnline ? .green : .gray)
                .frame(width: 6, height: 6)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack {
            ForEach(AgentInfo.samples) { agent in
                AgentStatusCard(agent: agent)
            }
        }
        .padding()
    }
}
