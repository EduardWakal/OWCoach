import Foundation
import SwiftData

@Model
final class VODReview {
    var key: String = UUID().uuidString
    var date: Date = Date()
    var replayCode: String = ""
    var heroID: String = ""
    var mapID: String = ""

    init() {}
}
