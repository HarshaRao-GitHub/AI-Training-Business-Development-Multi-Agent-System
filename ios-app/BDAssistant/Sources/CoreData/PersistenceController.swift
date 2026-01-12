//
//  PersistenceController.swift
//  BD Assistant
//
//  Core Data persistence controller for offline support
//

import CoreData
import Foundation

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    // MARK: - Preview Support
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // Create sample data for previews
        let lead = CachedLead(context: viewContext)
        lead.id = "preview-1"
        lead.companyName = "Preview Company"
        lead.industry = "Technology"
        lead.status = "QUALIFIED"
        lead.score = "HOT"
        lead.createdAt = Date()
        lead.updatedAt = Date()
        lead.isSynced = true

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return controller
    }()

    // MARK: - Initialization
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "BDAssistant")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Core Data error: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Save
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // MARK: - Background Context
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    // MARK: - Lead Operations
    func cacheLead(_ lead: Lead) {
        let context = container.viewContext

        let fetchRequest: NSFetchRequest<CachedLead> = CachedLead.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", lead.id)

        do {
            let results = try context.fetch(fetchRequest)
            let cachedLead = results.first ?? CachedLead(context: context)

            cachedLead.id = lead.id
            cachedLead.companyName = lead.companyName
            cachedLead.industry = lead.industry
            cachedLead.companySize = lead.companySize
            cachedLead.website = lead.website
            cachedLead.contactName = lead.contactName
            cachedLead.contactEmail = lead.contactEmail
            cachedLead.contactPhone = lead.contactPhone
            cachedLead.contactTitle = lead.contactTitle
            cachedLead.status = lead.status.rawValue
            cachedLead.score = lead.score.rawValue
            cachedLead.qualificationScore = Int16(lead.qualificationScore ?? 0)
            cachedLead.qualificationNotes = lead.qualificationNotes
            cachedLead.source = lead.source
            cachedLead.estimatedValue = lead.estimatedValue ?? 0
            cachedLead.notes = lead.notes
            cachedLead.nextAction = lead.nextAction
            cachedLead.nextActionDate = lead.nextActionDate
            cachedLead.createdAt = lead.createdAt
            cachedLead.updatedAt = lead.updatedAt
            cachedLead.isSynced = true

            // Store arrays as JSON
            if let signals = lead.aiAdoptionSignals {
                cachedLead.aiAdoptionSignalsJSON = try? JSONEncoder().encode(signals)
            }
            if let needs = lead.trainingNeeds {
                cachedLead.trainingNeedsJSON = try? JSONEncoder().encode(needs)
            }

            save()
        } catch {
            print("Failed to cache lead: \(error)")
        }
    }

    func getCachedLeads() -> [Lead] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<CachedLead> = CachedLead.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CachedLead.updatedAt, ascending: false)]

        do {
            let cachedLeads = try context.fetch(fetchRequest)
            return cachedLeads.compactMap { cached -> Lead? in
                guard let id = cached.id,
                      let companyName = cached.companyName,
                      let industry = cached.industry,
                      let statusString = cached.status,
                      let status = LeadStatus(rawValue: statusString),
                      let scoreString = cached.score,
                      let score = LeadScore(rawValue: scoreString) else {
                    return nil
                }

                var aiSignals: [String]?
                if let signalsData = cached.aiAdoptionSignalsJSON {
                    aiSignals = try? JSONDecoder().decode([String].self, from: signalsData)
                }

                var trainingNeeds: [String]?
                if let needsData = cached.trainingNeedsJSON {
                    trainingNeeds = try? JSONDecoder().decode([String].self, from: needsData)
                }

                return Lead(
                    id: id,
                    companyName: companyName,
                    industry: industry,
                    companySize: cached.companySize,
                    website: cached.website,
                    contactName: cached.contactName,
                    contactEmail: cached.contactEmail,
                    contactPhone: cached.contactPhone,
                    contactTitle: cached.contactTitle,
                    status: status,
                    score: score,
                    qualificationScore: cached.qualificationScore > 0 ? Int(cached.qualificationScore) : nil,
                    qualificationNotes: cached.qualificationNotes,
                    source: cached.source,
                    estimatedValue: cached.estimatedValue > 0 ? cached.estimatedValue : nil,
                    aiAdoptionSignals: aiSignals,
                    trainingNeeds: trainingNeeds,
                    decisionMakers: nil,
                    notes: cached.notes,
                    nextAction: cached.nextAction,
                    nextActionDate: cached.nextActionDate,
                    createdAt: cached.createdAt ?? Date(),
                    updatedAt: cached.updatedAt ?? Date()
                )
            }
        } catch {
            print("Failed to fetch cached leads: \(error)")
            return []
        }
    }

    func getUnsyncedLeads() -> [CachedLead] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<CachedLead> = CachedLead.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isSynced == NO")

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch unsynced leads: \(error)")
            return []
        }
    }

    func markLeadAsSynced(id: String) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<CachedLead> = CachedLead.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        do {
            if let lead = try context.fetch(fetchRequest).first {
                lead.isSynced = true
                save()
            }
        } catch {
            print("Failed to mark lead as synced: \(error)")
        }
    }

    // MARK: - Proposal Operations
    func cacheProposal(_ proposal: Proposal) {
        let context = container.viewContext

        let fetchRequest: NSFetchRequest<CachedProposal> = CachedProposal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", proposal.id)

        do {
            let results = try context.fetch(fetchRequest)
            let cached = results.first ?? CachedProposal(context: context)

            cached.id = proposal.id
            cached.leadId = proposal.leadId
            cached.title = proposal.title
            cached.executiveSummary = proposal.executiveSummary
            cached.status = proposal.status.rawValue
            cached.version = Int16(proposal.version)
            cached.createdAt = proposal.createdAt
            cached.updatedAt = proposal.updatedAt
            cached.isSynced = true

            if let pricing = proposal.pricing {
                cached.pricingJSON = try? JSONEncoder().encode(pricing)
            }

            save()
        } catch {
            print("Failed to cache proposal: \(error)")
        }
    }

    // MARK: - Brief Operations
    func cacheBrief(_ brief: IntelligenceBrief) {
        let context = container.viewContext

        let fetchRequest: NSFetchRequest<CachedBrief> = CachedBrief.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", brief.id)

        do {
            let results = try context.fetch(fetchRequest)
            let cached = results.first ?? CachedBrief(context: context)

            cached.id = brief.id
            cached.title = brief.title
            cached.summary = brief.summary
            cached.briefType = brief.briefType.rawValue
            cached.priority = brief.priority.rawValue
            cached.isRead = brief.isRead
            cached.createdAt = brief.createdAt

            if let insights = try? JSONEncoder().encode(brief.insights) {
                cached.insightsJSON = insights
            }
            if let recommendations = try? JSONEncoder().encode(brief.recommendations) {
                cached.recommendationsJSON = recommendations
            }

            save()
        } catch {
            print("Failed to cache brief: \(error)")
        }
    }

    // MARK: - Clear Cache
    func clearCache() {
        let context = container.viewContext

        let entities = ["CachedLead", "CachedProposal", "CachedBrief", "PendingSync"]

        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(deleteRequest)
            } catch {
                print("Failed to clear \(entity): \(error)")
            }
        }

        save()
    }
}

// MARK: - Core Data Model Classes
// These would normally be generated by Xcode, but we define them here for clarity

@objc(CachedLead)
public class CachedLead: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var companyName: String?
    @NSManaged public var industry: String?
    @NSManaged public var companySize: String?
    @NSManaged public var website: String?
    @NSManaged public var contactName: String?
    @NSManaged public var contactEmail: String?
    @NSManaged public var contactPhone: String?
    @NSManaged public var contactTitle: String?
    @NSManaged public var status: String?
    @NSManaged public var score: String?
    @NSManaged public var qualificationScore: Int16
    @NSManaged public var qualificationNotes: String?
    @NSManaged public var source: String?
    @NSManaged public var estimatedValue: Double
    @NSManaged public var notes: String?
    @NSManaged public var nextAction: String?
    @NSManaged public var nextActionDate: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var isSynced: Bool
    @NSManaged public var aiAdoptionSignalsJSON: Data?
    @NSManaged public var trainingNeedsJSON: Data?
}

extension CachedLead {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedLead> {
        return NSFetchRequest<CachedLead>(entityName: "CachedLead")
    }
}

@objc(CachedProposal)
public class CachedProposal: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var leadId: String?
    @NSManaged public var title: String?
    @NSManaged public var executiveSummary: String?
    @NSManaged public var status: String?
    @NSManaged public var version: Int16
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var isSynced: Bool
    @NSManaged public var pricingJSON: Data?
}

extension CachedProposal {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedProposal> {
        return NSFetchRequest<CachedProposal>(entityName: "CachedProposal")
    }
}

@objc(CachedBrief)
public class CachedBrief: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var summary: String?
    @NSManaged public var briefType: String?
    @NSManaged public var priority: String?
    @NSManaged public var isRead: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var insightsJSON: Data?
    @NSManaged public var recommendationsJSON: Data?
}

extension CachedBrief {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedBrief> {
        return NSFetchRequest<CachedBrief>(entityName: "CachedBrief")
    }
}

@objc(PendingSync)
public class PendingSync: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var entityType: String?
    @NSManaged public var entityId: String?
    @NSManaged public var action: String?
    @NSManaged public var payloadJSON: Data?
    @NSManaged public var createdAt: Date?
    @NSManaged public var retryCount: Int16
}

extension PendingSync {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PendingSync> {
        return NSFetchRequest<PendingSync>(entityName: "PendingSync")
    }
}
