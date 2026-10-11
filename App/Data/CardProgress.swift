import Foundation
import SwiftData

@Model
final class CardProgress {
    var cardID: String = ""
    var masteredAt: Date?

    init(cardID: String, masteredAt: Date?) {
        self.cardID = cardID
        self.masteredAt = masteredAt
    }
}
