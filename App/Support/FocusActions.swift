import Foundation
import SwiftData

enum FocusActions {
    @MainActor
    static func setFocus(_ cardID: String?, in context: ModelContext) {
        FocusPlan.current(in: context).activeCardID = cardID
        try? context.save()
    }

    @MainActor
    static func markMastered(_ cardID: String, in context: ModelContext) {
        let descriptor = FetchDescriptor<CardProgress>(predicate: #Predicate { $0.cardID == cardID })
        if let existing = try? context.fetch(descriptor), !existing.isEmpty {
            existing.forEach { $0.masteredAt = .now }
        } else {
            context.insert(CardProgress(cardID: cardID, masteredAt: .now))
        }
        let plan = FocusPlan.current(in: context)
        if plan.activeCardID == cardID { plan.activeCardID = nil }
        try? context.save()
    }

    @MainActor
    static func deleteReview(_ review: VODReview, in context: ModelContext) {
        let reviewKey = review.key
        let descriptor = FetchDescriptor<Finding>(predicate: #Predicate { $0.reviewKey == reviewKey })
        (try? context.fetch(descriptor))?.forEach(context.delete)
        context.delete(review)
        try? context.save()
    }
}
