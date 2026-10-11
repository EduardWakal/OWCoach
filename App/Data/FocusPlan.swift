import Foundation
import SwiftData

@Model
final class FocusPlan {
    var activeCardID: String?
    var weekHeroIDs: [String] = []
    var createdAt: Date = Date()

    init() {}

    @MainActor
    static func current(in context: ModelContext) -> FocusPlan {
        let descriptor = FetchDescriptor<FocusPlan>(sortBy: [SortDescriptor(\.createdAt)])
        if let oldest = try? context.fetch(descriptor).first { return oldest }
        let state = FocusPlan()
        context.insert(state)
        return state
    }
}
