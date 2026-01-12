//
//  Proposal.swift
//  BD Assistant
//
//  Proposal model matching the backend API schema
//

import Foundation

// MARK: - Proposal Status
enum ProposalStatus: String, Codable, CaseIterable {
    case draft = "DRAFT"
    case pending = "PENDING"
    case sent = "SENT"
    case viewed = "VIEWED"
    case accepted = "ACCEPTED"
    case rejected = "REJECTED"
    case expired = "EXPIRED"

    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .pending: return "Pending Review"
        case .sent: return "Sent"
        case .viewed: return "Viewed"
        case .accepted: return "Accepted"
        case .rejected: return "Rejected"
        case .expired: return "Expired"
        }
    }

    var iconName: String {
        switch self {
        case .draft: return "doc.badge.ellipsis"
        case .pending: return "clock"
        case .sent: return "paperplane"
        case .viewed: return "eye"
        case .accepted: return "checkmark.circle"
        case .rejected: return "xmark.circle"
        case .expired: return "clock.badge.xmark"
        }
    }
}

// MARK: - Proposal Model
struct Proposal: Codable, Identifiable, Hashable {
    let id: String
    var leadId: String
    var title: String
    var executiveSummary: String?
    var trainingModules: [TrainingModule]?
    var deliveryFormat: String?
    var timeline: String?
    var pricing: ProposalPricing?
    var terms: String?
    var customizations: [String]?
    var status: ProposalStatus
    var version: Int
    var sentAt: Date?
    var viewedAt: Date?
    var responseAt: Date?
    var expiresAt: Date?
    var createdAt: Date
    var updatedAt: Date

    // Computed properties
    var isActive: Bool {
        switch status {
        case .draft, .pending, .sent, .viewed:
            return true
        case .accepted, .rejected, .expired:
            return false
        }
    }

    var daysUntilExpiry: Int? {
        guard let expiresAt = expiresAt else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expiresAt).day
        return days
    }

    enum CodingKeys: String, CodingKey {
        case id
        case leadId = "lead_id"
        case title
        case executiveSummary = "executive_summary"
        case trainingModules = "training_modules"
        case deliveryFormat = "delivery_format"
        case timeline
        case pricing
        case terms
        case customizations
        case status
        case version
        case sentAt = "sent_at"
        case viewedAt = "viewed_at"
        case responseAt = "response_at"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Training Module
struct TrainingModule: Codable, Hashable, Identifiable {
    var id: String { name }
    let name: String
    let description: String?
    let duration: String?
    let format: String?
    let objectives: [String]?
    let prerequisites: [String]?
}

// MARK: - Proposal Pricing
struct ProposalPricing: Codable, Hashable {
    let basePrice: Double?
    let discount: Double?
    let finalPrice: Double?
    let currency: String?
    let paymentTerms: String?
    let includedItems: [String]?
    let optionalAddOns: [AddOn]?

    enum CodingKeys: String, CodingKey {
        case basePrice = "base_price"
        case discount
        case finalPrice = "final_price"
        case currency
        case paymentTerms = "payment_terms"
        case includedItems = "included_items"
        case optionalAddOns = "optional_add_ons"
    }
}

struct AddOn: Codable, Hashable {
    let name: String
    let price: Double
    let description: String?
}

// MARK: - Proposal Generation Request
struct ProposalGenerationRequest: Codable {
    let leadId: String
    let trainingNeeds: [String]?
    let budget: Double?
    let timeline: String?
    let deliveryPreference: String?
    let customRequirements: String?

    enum CodingKeys: String, CodingKey {
        case leadId = "lead_id"
        case trainingNeeds = "training_needs"
        case budget
        case timeline
        case deliveryPreference = "delivery_preference"
        case customRequirements = "custom_requirements"
    }
}

// MARK: - Sample Data
extension Proposal {
    static var sample: Proposal {
        Proposal(
            id: "proposal-1",
            leadId: "sample-1",
            title: "AI Training Program for TechCorp Industries",
            executiveSummary: "Comprehensive AI training program designed to upskill your workforce in practical AI applications, prompt engineering, and responsible AI usage.",
            trainingModules: [
                TrainingModule(
                    name: "Prompt Engineering Fundamentals",
                    description: "Master the art of crafting effective prompts for AI systems",
                    duration: "2 days",
                    format: "In-person workshop",
                    objectives: ["Understand prompt design principles", "Write effective prompts", "Iterate and optimize"],
                    prerequisites: nil
                ),
                TrainingModule(
                    name: "AI Ethics & Governance",
                    description: "Learn responsible AI practices and governance frameworks",
                    duration: "1 day",
                    format: "Virtual session",
                    objectives: ["Understand AI bias", "Implement ethical guidelines", "Risk assessment"],
                    prerequisites: nil
                )
            ],
            deliveryFormat: "Hybrid (In-person + Virtual)",
            timeline: "4 weeks",
            pricing: ProposalPricing(
                basePrice: 150000,
                discount: 10,
                finalPrice: 135000,
                currency: "USD",
                paymentTerms: "50% upfront, 50% on completion",
                includedItems: ["Training materials", "Certification", "30-day support"],
                optionalAddOns: [
                    AddOn(name: "Extended Support", price: 15000, description: "90-day post-training support")
                ]
            ),
            terms: "Valid for 30 days from proposal date",
            customizations: ["Custom case studies for tech industry", "Leadership track included"],
            status: .sent,
            version: 2,
            sentAt: Date().addingTimeInterval(-86400 * 3),
            viewedAt: Date().addingTimeInterval(-86400 * 2),
            responseAt: nil,
            expiresAt: Date().addingTimeInterval(86400 * 27),
            createdAt: Date().addingTimeInterval(-86400 * 7),
            updatedAt: Date().addingTimeInterval(-86400 * 3)
        )
    }

    static var samples: [Proposal] {
        [
            sample,
            Proposal(
                id: "proposal-2",
                leadId: "sample-2",
                title: "AI for Finance Training - FinanceFlow Inc",
                executiveSummary: "Specialized AI training program for financial services professionals.",
                trainingModules: nil,
                deliveryFormat: "Virtual",
                timeline: "6 weeks",
                pricing: ProposalPricing(
                    basePrice: 250000,
                    discount: nil,
                    finalPrice: 250000,
                    currency: "USD",
                    paymentTerms: nil,
                    includedItems: nil,
                    optionalAddOns: nil
                ),
                terms: nil,
                customizations: nil,
                status: .draft,
                version: 1,
                sentAt: nil,
                viewedAt: nil,
                responseAt: nil,
                expiresAt: nil,
                createdAt: Date().addingTimeInterval(-86400 * 2),
                updatedAt: Date()
            )
        ]
    }
}
