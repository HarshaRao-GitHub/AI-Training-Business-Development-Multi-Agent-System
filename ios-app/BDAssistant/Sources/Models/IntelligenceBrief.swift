//
//  IntelligenceBrief.swift
//  BD Assistant
//
//  Intelligence brief models for market research and insights
//

import Foundation

// MARK: - Intelligence Brief
struct IntelligenceBrief: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String
    let briefType: BriefType
    let priority: BriefPriority
    let insights: [Insight]
    let recommendations: [String]
    let sources: [String]?
    let relatedLeads: [String]?
    let isRead: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case summary
        case briefType = "brief_type"
        case priority
        case insights
        case recommendations
        case sources
        case relatedLeads = "related_leads"
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}

// MARK: - Brief Type
enum BriefType: String, Codable, CaseIterable {
    case daily = "DAILY"
    case weekly = "WEEKLY"
    case marketUpdate = "MARKET_UPDATE"
    case competitorAlert = "COMPETITOR_ALERT"
    case opportunityAlert = "OPPORTUNITY_ALERT"
    case trendAnalysis = "TREND_ANALYSIS"

    var displayName: String {
        switch self {
        case .daily: return "Daily Brief"
        case .weekly: return "Weekly Brief"
        case .marketUpdate: return "Market Update"
        case .competitorAlert: return "Competitor Alert"
        case .opportunityAlert: return "Opportunity Alert"
        case .trendAnalysis: return "Trend Analysis"
        }
    }

    var iconName: String {
        switch self {
        case .daily: return "sun.max"
        case .weekly: return "calendar"
        case .marketUpdate: return "chart.line.uptrend.xyaxis"
        case .competitorAlert: return "exclamationmark.triangle"
        case .opportunityAlert: return "star"
        case .trendAnalysis: return "waveform.path.ecg"
        }
    }
}

// MARK: - Brief Priority
enum BriefPriority: String, Codable, CaseIterable {
    case high = "HIGH"
    case medium = "MEDIUM"
    case low = "LOW"

    var color: String {
        switch self {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "blue"
        }
    }
}

// MARK: - Insight
struct Insight: Codable, Hashable, Identifiable {
    var id: String { title }
    let title: String
    let description: String
    let category: InsightCategory
    let confidence: Double?
    let actionItems: [String]?

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case category
        case confidence
        case actionItems = "action_items"
    }
}

enum InsightCategory: String, Codable {
    case market = "MARKET"
    case competitor = "COMPETITOR"
    case technology = "TECHNOLOGY"
    case regulation = "REGULATION"
    case opportunity = "OPPORTUNITY"
}

// MARK: - Market Research Request
struct MarketResearchRequest: Codable {
    let industry: String
    let region: String?
    let topics: [String]?
    let depth: String?

    enum CodingKeys: String, CodingKey {
        case industry
        case region
        case topics
        case depth
    }
}

// MARK: - Market Research Response
struct MarketResearchResponse: Codable {
    let industry: String
    let marketSize: String?
    let growthRate: String?
    let keyTrends: [String]
    let aiAdoptionRate: String?
    let trainingBudgetTrends: String?
    let topCompetitors: [CompetitorInfo]?
    let opportunities: [String]
    let challenges: [String]
    let recommendations: [String]

    enum CodingKeys: String, CodingKey {
        case industry
        case marketSize = "market_size"
        case growthRate = "growth_rate"
        case keyTrends = "key_trends"
        case aiAdoptionRate = "ai_adoption_rate"
        case trainingBudgetTrends = "training_budget_trends"
        case topCompetitors = "top_competitors"
        case opportunities
        case challenges
        case recommendations
    }
}

struct CompetitorInfo: Codable, Hashable {
    let name: String
    let strengths: [String]?
    let weaknesses: [String]?
    let marketPosition: String?

    enum CodingKeys: String, CodingKey {
        case name
        case strengths
        case weaknesses
        case marketPosition = "market_position"
    }
}

// MARK: - Sample Data
extension IntelligenceBrief {
    static var sample: IntelligenceBrief {
        IntelligenceBrief(
            id: "brief-1",
            title: "Morning Intelligence Brief - Jan 4, 2026",
            summary: "Key developments in AI training market: increased enterprise adoption of LLMs, new regulatory considerations in EU, and emerging opportunities in healthcare sector.",
            briefType: .daily,
            priority: .high,
            insights: [
                Insight(
                    title: "Enterprise LLM Adoption Accelerating",
                    description: "Fortune 500 companies reporting 40% increase in AI training budgets for Q1 2026",
                    category: .market,
                    confidence: 0.85,
                    actionItems: ["Prioritize enterprise outreach", "Update pricing for enterprise tier"]
                ),
                Insight(
                    title: "Healthcare AI Training Gap",
                    description: "Healthcare organizations struggling to find specialized AI training for clinical staff",
                    category: .opportunity,
                    confidence: 0.78,
                    actionItems: ["Develop healthcare-specific curriculum", "Partner with medical associations"]
                )
            ],
            recommendations: [
                "Focus outreach on healthcare sector this week",
                "Prepare EU compliance module for training programs",
                "Schedule calls with 3 Fortune 500 prospects"
            ],
            sources: ["Industry Reports", "News Analysis", "Social Listening"],
            relatedLeads: ["sample-1", "sample-2"],
            isRead: false,
            createdAt: Date()
        )
    }

    static var samples: [IntelligenceBrief] {
        [
            sample,
            IntelligenceBrief(
                id: "brief-2",
                title: "Competitor Alert: NewAI Training Launch",
                summary: "NewAI Corp announced comprehensive AI training platform with aggressive pricing.",
                briefType: .competitorAlert,
                priority: .high,
                insights: [
                    Insight(
                        title: "New Market Entrant",
                        description: "NewAI Corp launching enterprise training at 20% below market rates",
                        category: .competitor,
                        confidence: 0.92,
                        actionItems: ["Review pricing strategy", "Emphasize differentiation"]
                    )
                ],
                recommendations: ["Prepare competitive analysis", "Update sales battle cards"],
                sources: ["Press Release", "Industry News"],
                relatedLeads: nil,
                isRead: true,
                createdAt: Date().addingTimeInterval(-86400)
            ),
            IntelligenceBrief(
                id: "brief-3",
                title: "Weekly Market Summary",
                summary: "Overview of AI training market developments for the past week.",
                briefType: .weekly,
                priority: .medium,
                insights: [],
                recommendations: [],
                sources: nil,
                relatedLeads: nil,
                isRead: true,
                createdAt: Date().addingTimeInterval(-86400 * 7)
            )
        ]
    }
}
