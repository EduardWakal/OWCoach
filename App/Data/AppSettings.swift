import Foundation
import OWCoachKit
import SwiftData

@Model
final class AppSettings {
    var defaultRoleRaw: String?
    var mode: String = "5v5"
    var poolHeroIDs: [String] = []
    var dismissedJSON: Data?
    var createdAt: Date = Date()

    init() {}

    var defaultRole: Role? {
        get { defaultRoleRaw.flatMap(Role.init(rawValue:)) }
        set { defaultRoleRaw = newValue?.rawValue }
    }

    var dismissed: [String: Int] {
        get { dismissedJSON.flatMap { try? JSONDecoder().decode([String: Int].self, from: $0) } ?? [:] }
        set { dismissedJSON = try? JSONEncoder().encode(newValue) }
    }

    @MainActor
    static func current(in context: ModelContext) -> AppSettings {
        let descriptor = FetchDescriptor<AppSettings>(sortBy: [SortDescriptor(\.createdAt)])
        if let oldest = try? context.fetch(descriptor).first { return oldest }
        let settings = AppSettings()
        context.insert(settings)
        return settings
    }
}
