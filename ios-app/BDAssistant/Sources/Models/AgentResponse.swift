//
//  AgentResponse.swift
//  BD Assistant
//
//  Models for agent responses and dashboard data
//

import Foundation

// MARK: - Health Check Response
struct HealthCheckResponse: Codable {
    let status: String
    let version: String?
    let agents: [String: AgentStatus]?
}

struct AgentStatus: Codable {
    let name: String
    let status: String
    let lastActive: Date?

    enum CodingKeys: String, CodingKey {
        case name
        case status
        case lastActive = "last_active"
    }
}

// MARK: - Dashboard Metrics
struct DashboardMetrics: Codable {
    let totalLeads: Int
    let hotLeads: Int
    let warmLeads: Int
    let coldLeads: Int
    let pendingProposals: Int
    let proposalsThisMonth: Int
    let winRate: Double
    let pipelineValue: Double
    let hasUnreadBriefs: Bool
    let agentsOnline: Int
    let lastSync: Date?

    enum CodingKeys: String, CodingKey {
        case totalLeads = "total_leads"
        case hotLeads = "hot_leads"
        case warmLeads = "warm_leads"
        case coldLeads = "cold_leads"
        case pendingProposals = "pending_proposals"
        case proposalsThisMonth = "proposals_this_month"
        case winRate = "win_rate"
        case pipelineValue = "pipeline_value"
        case hasUnreadBriefs = "has_unread_briefs"
        case agentsOnline = "agents_online"
        case lastSync = "last_sync"
    }
}

// MARK: - Agent Info
struct AgentInfo: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let displayName: String
    let description: String
    let status: String
    let capabilities: [String]
    let lastUsed: Date?

    enum CodingKeys: String, CodingKey {
        case name
        case displayName = "display_name"
        case description
        case status
        case capabilities
        case lastUsed = "last_used"
    }

    var iconName: String {
        switch name {
        case "orchestrator": return "cpu"
        case "research": return "magnifyingglass"
        case "lead_gen": return "person.badge.plus"
        case "content": return "doc.text"
        case "relationship": return "heart.text.square"
        case "knowledge": return "brain"
        case "analytics": return "chart.bar"
        default: return "questionmark.circle"
        }
    }

    var isOnline: Bool {
        status.lowercased() == "online" || status.lowercased() == "active"
    }
}

// MARK: - Pipeline Analytics
struct PipelineAnalytics: Codable {
    let totalValue: Double
    let averageDealSize: Double
    let conversionRate: Double
    let averageSalesCycle: Int
    let stageBreakdown: [StageData]
    let monthlyTrend: [MonthlyData]
    let topPerformingIndustries: [IndustryData]

    enum CodingKeys: String, CodingKey {
        case totalValue = "total_value"
        case averageDealSize = "average_deal_size"
        case conversionRate = "conversion_rate"
        case averageSalesCycle = "average_sales_cycle"
        case stageBreakdown = "stage_breakdown"
        case monthlyTrend = "monthly_trend"
        case topPerformingIndustries = "top_performing_industries"
    }
}

struct StageData: Codable, Identifiable {
    var id: String { stage }
    let stage: String
    let count: Int
    let value: Double
}

struct MonthlyData: Codable, Identifiable {
    var id: String { month }
    let month: String
    let leads: Int
    let proposals: Int
    let won: Int
    let value: Double
}

struct IndustryData: Codable, Identifiable {
    var id: String { industry }
    let industry: String
    let leads: Int
    let winRate: Double
    let averageValue: Double

    enum CodingKeys: String, CodingKey {
        case industry
        case leads
        case winRate = "win_rate"
        case averageValue = "average_value"
    }
}

// MARK: - Daily Routine
struct DailyRoutine: Codable {
    let date: Date
    let morningBrief: String?
    let priorityLeads: [Lead]
    let scheduledFollowUps: [FollowUp]
    let suggestedActions: [SuggestedAction]
    let marketUpdates: [String]

    enum CodingKeys: String, CodingKey {
        case date
        case morningBrief = "morning_brief"
        case priorityLeads = "priority_leads"
        case scheduledFollowUps = "scheduled_follow_ups"
        case suggestedActions = "suggested_actions"
        case marketUpdates = "market_updates"
    }
}

struct FollowUp: Codable, Identifiable {
    let id: String
    let leadId: String
    let companyName: String
    let action: String
    let dueDate: Date
    let priority: String

    enum CodingKeys: String, CodingKey {
        case id
        case leadId = "lead_id"
        case companyName = "company_name"
        case action
        case dueDate = "due_date"
        case priority
    }
}

struct SuggestedAction: Codable, Identifiable {
    let id: String
    let action: String
    let reason: String
    let impact: String
    let relatedLeadId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case action
        case reason
        case impact
        case relatedLeadId = "related_lead_id"
    }
}

// MARK: - Sample Data
extension DashboardMetrics {
    static var sample: DashboardMetrics {
        DashboardMetrics(
            totalLeads: 127,
            hotLeads: 12,
            warmLeads: 34,
            coldLeads: 81,
            pendingProposals: 5,
            proposalsThisMonth: 8,
            winRate: 0.32,
            pipelineValue: 1250000,
            hasUnreadBriefs: true,
            agentsOnline: 7,
            lastSync: Date()
        )
    }
}

extension AgentInfo {
    static var samples: [AgentInfo] {
        [
            AgentInfo(name: "orchestrator", displayName: "Orchestrator", description: "Coordinates all agents", status: "online", capabilities: ["task_routing", "coordination"], lastUsed: Date()),
            AgentInfo(name: "research", displayName: "Research & Intelligence", description: "Market research and analysis", status: "online", capabilities: ["market_analysis", "competitor_research"], lastUsed: Date()),
            AgentInfo(name: "lead_gen", displayName: "Lead Generation", description: "Lead qualification and scoring", status: "online", capabilities: ["lead_scoring", "qualification"], lastUsed: Date()),
            AgentInfo(name: "content", displayName: "Content & Proposals", description: "Generate proposals and content", status: "online", capabilities: ["proposal_generation", "email_templates"], lastUsed: Date()),
            AgentInfo(name: "relationship", displayName: "Relationship Management", description: "Track and manage relationships", status: "online", capabilities: ["sentiment_analysis", "follow_up_planning"], lastUsed: Date()),
            AgentInfo(name: "knowledge", displayName: "Knowledge Management", description: "Institutional knowledge and RAG", status: "online", capabilities: ["semantic_search", "case_retrieval"], lastUsed: Date()),
            AgentInfo(name: "analytics", displayName: "Analytics & Reporting", description: "Pipeline and performance analytics", status: "online", capabilities: ["forecasting", "reporting"], lastUsed: Date())
        ]
    }
}
