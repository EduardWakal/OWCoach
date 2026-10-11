import Foundation

public enum Suggestion: Hashable, Sendable {
    case cardMastered(cardID: String)
    case switchFocus(cause: DeathCause, cardID: String)
    case moveOn(cardID: String)

    public var key: String {
        switch self {
        case .cardMastered(let id): "mastered:\(id)"
        case .switchFocus(_, let id): "switch:\(id)"
        case .moveOn(let id): "moveOn:\(id)"
        }
    }
}

public struct SuggestionInput: Sendable {
    public var games: [GameRecord]
    public var activeCardID: String?
    public var masteredCardIDs: Set<String>
    public var dismissedAtGameCount: [String: Int]

    public init(games: [GameRecord], activeCardID: String?, masteredCardIDs: Set<String>, dismissedAtGameCount: [String: Int]) {
        self.games = games
        self.activeCardID = activeCardID
        self.masteredCardIDs = masteredCardIDs
        self.dismissedAtGameCount = dismissedAtGameCount
    }
}

public enum SuggestionEngine {
    static let masteryDays = 3
    static let masteryAverage = 4.0
    static let moveOnDays = 10
    static let causeWindow = 10
    static let causeMinimumGames = 4
    static let causeShare = 0.4
    static let dismissCooldown = 3

    public static func suggestion(for input: SuggestionInput, calendar: Calendar = .current) -> Suggestion? {
        let candidates = [mastered(input, calendar), switchFocus(input), moveOn(input, calendar)].compactMap { $0 }
        return candidates.first { candidate in
            guard let dismissedAt = input.dismissedAtGameCount[candidate.key] else { return true }
            return input.games.count - dismissedAt >= dismissCooldown
        }
    }

    static func mastered(_ input: SuggestionInput, _ calendar: Calendar) -> Suggestion? {
        guard let card = input.activeCardID, !input.masteredCardIDs.contains(card) else { return nil }
        let days = Stats.playDays(input.games.filter { $0.focusCardID == card }, calendar: calendar)
        guard days.count >= masteryDays else { return nil }
        let good = days.suffix(masteryDays).allSatisfy { (Stats.focusAverage($0.games) ?? 0) >= masteryAverage }
        return good ? .cardMastered(cardID: card) : nil
    }

    static func switchFocus(_ input: SuggestionInput) -> Suggestion? {
        let window = input.games.sorted { $0.date < $1.date }.suffix(causeWindow)
        guard window.count >= causeMinimumGames else { return nil }
        var best: (cause: DeathCause, share: Double)?
        for cause in DeathCause.allCases {
            guard let cardID = cause.basicCardID, cardID != input.activeCardID, !input.masteredCardIDs.contains(cardID) else { continue }
            let share = Double(window.filter { $0.deathCause == cause }.count) / Double(window.count)
            if share >= causeShare, share > (best?.share ?? 0) { best = (cause, share) }
        }
        guard let best, let cardID = best.cause.basicCardID else { return nil }
        return .switchFocus(cause: best.cause, cardID: cardID)
    }

    static func moveOn(_ input: SuggestionInput, _ calendar: Calendar) -> Suggestion? {
        guard let card = input.activeCardID, !input.masteredCardIDs.contains(card) else { return nil }
        let days = Stats.playDays(input.games.filter { $0.focusCardID == card }, calendar: calendar)
        return days.count >= moveOnDays ? .moveOn(cardID: card) : nil
    }
}
