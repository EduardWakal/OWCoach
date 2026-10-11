import Foundation
import OWCoachKit
import SwiftData

enum Singletons {
    @MainActor
    static func consolidate(in context: ModelContext) {
        let settings = (try? context.fetch(FetchDescriptor<AppSettings>(sortBy: [SortDescriptor(\.createdAt)]))) ?? []
        if let keep = settings.first, settings.count > 1 {
            keep.poolHeroIDs = SingletonMerge.union(settings.map(\.poolHeroIDs))
            keep.defaultRoleRaw = SingletonMerge.first(settings.map(\.defaultRoleRaw))
            keep.dismissed = SingletonMerge.dismissed(settings.map(\.dismissed))
            settings.dropFirst().forEach(context.delete)
        }
        let plans = (try? context.fetch(FetchDescriptor<FocusPlan>(sortBy: [SortDescriptor(\.createdAt)]))) ?? []
        if let keep = plans.first, plans.count > 1 {
            keep.weekHeroIDs = SingletonMerge.union(plans.map(\.weekHeroIDs))
            keep.activeCardID = SingletonMerge.first(plans.map(\.activeCardID))
            plans.dropFirst().forEach(context.delete)
        }
        if context.hasChanges { try? context.save() }
    }
}
