//
//  Lead.swift
//  BD Assistant
//
//  Lead model matching the backend API schema
//

import Foundation

// MARK: - Lead Status
enum LeadStatus: String, Codable, CaseIterable {
    case new = "NEW"
    case qualified = "QUALIFIED"
    case contacted = "CONTACTED"
    case proposalSent = "PROPOSAL_SENT"
    case negotiation = "NEGOTIATION"
    case won = "WON"
    case lost = "LOST"
    case inactive = "INACTIVE"

    var displayName: String {
        switch self {
        case .new: return "New"
        case .qualified: return "Qualified"
        case .contacted: return "Contacted"
        case .proposalSent: return "Proposal Sent"
        case .negotiation: return "Negotiation"
        case .won: return "Won"
        case .lost: return "Lost"
        case .inactive: return "Inactive"
        }
    }

    var color: String {
        switch self {
        case .new: return "blue"
        case .qualified: return "green"
        case .contacted: return "orange"
        case .proposalSent: return "purple"
        case .negotiation: return "yellow"
        case .won: return "green"
        case .lost: return "red"
        case .inactive: return "gray"
        }
    }
}

// MARK: - Lead Score
enum LeadScore: String, Codable, CaseIterable {
    case hot = "HOT"
    case warm = "WARM"
    case cold = "COLD"

    var displayName: String {
        switch self {
        case .hot: return "Hot"
        case .warm: return "Warm"
        case .cold: return "Cold"
        }
    }

    var emoji: String {
        switch self {
        case .hot: return "🔥"
        case .warm: return "🌡️"
        case .cold: return "❄️"
        }
    }
}

// MARK: - Lead Model
struct Lead: Codable, Identifiable, Hashable {
    let id: String
    var companyName: String
    var industry: String
    var companySize: String?
    var website: String?
    var contactName: String?
    var contactEmail: String?
    var contactPhone: String?
    var contactTitle: String?
    var status: LeadStatus
    var score: LeadScore
    var qualificationScore: Int?
    var qualificationNotes: String?
    var source: String?
    var estimatedValue: Double?
    var aiAdoptionSignals: [String]?
    var trainingNeeds: [String]?
    var decisionMakers: [DecisionMaker]?
    var notes: String?
    var nextAction: String?
    var nextActionDate: Date?
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case companyName = "company_name"
        case industry
        case companySize = "company_size"
        case website
        case contactName = "contact_name"
        case contactEmail = "contact_email"
        case contactPhone = "contact_phone"
        case contactTitle = "contact_title"
        case status
        case score
        case qualificationScore = "qualification_score"
        case qualificationNotes = "qualification_notes"
        case source
        case estimatedValue = "estimated_value"
        case aiAdoptionSignals = "ai_adoption_signals"
        case trainingNeeds = "training_needs"
        case decisionMakers = "decision_makers"
        case notes
        case nextAction = "next_action"
        case nextActionDate = "next_action_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Decision Maker
struct DecisionMaker: Codable, Hashable {
    let name: String
    let title: String
    let email: String?
    let phone: String?
    let linkedinUrl: String?
    let influence: String?

    enum CodingKeys: String, CodingKey {
        case name
        case title
        case email
        case phone
        case linkedinUrl = "linkedin_url"
        case influence
    }
}

// MARK: - Lead Qualification Request
struct LeadQualificationRequest: Codable {
    let companyName: String
    let industry: String?
    let companySize: String?
    let website: String?
    let additionalContext: String?

    enum CodingKeys: String, CodingKey {
        case companyName = "company_name"
        case industry
        case companySize = "company_size"
        case website
        case additionalContext = "additional_context"
    }
}

// MARK: - Lead Qualification Response
struct LeadQualificationResponse: Codable {
    let qualificationScore: Int
    let scoreBreakdown: ScoreBreakdown?
    let recommendation: String
    let trainingNeeds: [String]
    let decisionMakers: [DecisionMaker]
    let aiAdoptionSignals: [String]
    let suggestedNextSteps: [String]

    enum CodingKeys: String, CodingKey {
        case qualificationScore = "qualification_score"
        case scoreBreakdown = "score_breakdown"
        case recommendation
        case trainingNeeds = "training_needs"
        case decisionMakers = "decision_makers"
        case aiAdoptionSignals = "ai_adoption_signals"
        case suggestedNextSteps = "suggested_next_steps"
    }
}

struct ScoreBreakdown: Codable {
    let budget: Int?
    let authority: Int?
    let need: Int?
    let timeline: Int?
}

// MARK: - Sample Data
extension Lead {
    static var sample: Lead {
        Lead(
            id: "sample-1",
            companyName: "TechCorp Industries",
            industry: "Technology",
            companySize: "500-1000",
            website: "https://techcorp.example.com",
            contactName: "Jane Smith",
            contactEmail: "jane@techcorp.example.com",
            contactPhone: "+1-555-0123",
            contactTitle: "VP of Training",
            status: .qualified,
            score: .hot,
            qualificationScore: 85,
            qualificationNotes: "Strong AI adoption signals, budget approved",
            source: "LinkedIn",
            estimatedValue: 150000,
            aiAdoptionSignals: ["ChatGPT Enterprise", "GitHub Copilot", "AI job postings"],
            trainingNeeds: ["Prompt Engineering", "AI Ethics", "LLM Integration"],
            decisionMakers: [
                DecisionMaker(name: "Jane Smith", title: "VP of Training", email: "jane@techcorp.example.com", phone: nil, linkedinUrl: nil, influence: "High")
            ],
            notes: "Very interested in comprehensive AI training program",
            nextAction: "Schedule discovery call",
            nextActionDate: Date().addingTimeInterval(86400 * 3),
            createdAt: Date().addingTimeInterval(-86400 * 7),
            updatedAt: Date()
        )
    }

    static var samples: [Lead] {
        [
            sample,
            Lead(
                id: "sample-2",
                companyName: "FinanceFlow Inc",
                industry: "Finance",
                companySize: "1000-5000",
                website: "https://financeflow.example.com",
                contactName: "Robert Chen",
                contactEmail: "rchen@financeflow.example.com",
                contactPhone: nil,
                contactTitle: "Director of L&D",
                status: .contacted,
                score: .warm,
                qualificationScore: 72,
                qualificationNotes: nil,
                source: "Referral",
                estimatedValue: 250000,
                aiAdoptionSignals: ["AI strategy initiative"],
                trainingNeeds: ["AI for Finance", "Risk Assessment with AI"],
                decisionMakers: nil,
                notes: nil,
                nextAction: "Send case study",
                nextActionDate: Date().addingTimeInterval(86400),
                createdAt: Date().addingTimeInterval(-86400 * 14),
                updatedAt: Date().addingTimeInterval(-86400 * 2)
            ),
            Lead(
                id: "sample-3",
                companyName: "HealthTech Solutions",
                industry: "Healthcare",
                companySize: "200-500",
                website: nil,
                contactName: "Maria Garcia",
                contactEmail: "mgarcia@healthtech.example.com",
                contactPhone: nil,
                contactTitle: "CEO",
                status: .new,
                score: .cold,
                qualificationScore: 45,
                qualificationNotes: nil,
                source: "Website",
                estimatedValue: 75000,
                aiAdoptionSignals: nil,
                trainingNeeds: nil,
                decisionMakers: nil,
                notes: "Initial inquiry through website form",
                nextAction: "Initial outreach",
                nextActionDate: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }
}
