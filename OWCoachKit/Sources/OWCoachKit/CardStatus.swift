import Foundation

public enum CardStatus: Sendable {
    case open, active, mastered

    public static func of(_ cardID: String, active: String?, mastered: Set<String>) -> CardStatus {
        if cardID == active { return .active }
        return mastered.contains(cardID) ? .mastered : .open
    }
}
