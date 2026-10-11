import Foundation
import OWCoachKit
import SwiftData

@Model
final class Finding {
    var key: String = UUID().uuidString
    var reviewKey: String = ""
    var cardID: String = ""
    var text: String = ""
    var moment: String?
    var starred: Bool = false
    var date: Date = Date()

    init(reviewKey: String, cardID: String, text: String, moment: String?, starred: Bool) {
        self.reviewKey = reviewKey
        self.cardID = cardID
        self.text = text
        self.moment = moment
        self.starred = starred
    }

    var record: FindingRecord {
        FindingRecord(key: key, reviewKey: reviewKey, cardID: cardID, text: text, moment: moment, starred: starred, date: date)
    }
}
