import Foundation

public struct FindingRecord: Hashable, Sendable, Identifiable {
    public var key: String
    public var reviewKey: String
    public var cardID: String
    public var text: String
    public var moment: String?
    public var starred: Bool
    public var date: Date

    public var id: String { key }

    public init(key: String, reviewKey: String, cardID: String, text: String, moment: String?, starred: Bool, date: Date) {
        self.key = key
        self.reviewKey = reviewKey
        self.cardID = cardID
        self.text = text
        self.moment = moment
        self.starred = starred
        self.date = date
    }
}

public struct CardLearnings: Hashable, Sendable, Identifiable {
    public let cardID: String
    public let findings: [FindingRecord]

    public var id: String { cardID }
}

public enum Learnings {
    public static func forCard(_ cardID: String, in findings: [FindingRecord]) -> [FindingRecord] {
        findings.filter { $0.cardID == cardID }.sorted { ($0.starred ? 1 : 0, $0.date) > ($1.starred ? 1 : 0, $1.date) }
    }

    public static func starred(for cardID: String, in findings: [FindingRecord]) -> [FindingRecord] {
        forCard(cardID, in: findings).filter(\.starred)
    }

    public static func grouped(_ findings: [FindingRecord]) -> [CardLearnings] {
        Dictionary(grouping: findings, by: \.cardID)
            .map { CardLearnings(cardID: $0.key, findings: forCard($0.key, in: $0.value)) }
            .sorted { ($0.findings.count, $1.cardID) > ($1.findings.count, $0.cardID) }
    }
}
