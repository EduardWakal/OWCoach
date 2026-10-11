import Foundation

public struct GameDraft: Sendable {
    public enum Step: Int, CaseIterable, Sendable {
        case role, hero, map, result, focus, death, tilt
    }

    public var step: Step = .role
    public var role: Role?
    public var heroID: String?
    public var mapID: String?
    public var result: GameResult?
    public var focus: Int?
    public var deathCause: DeathCause?
    public var tilt: Int?

    public init(defaultRole: Role?) {
        role = defaultRole
    }

    public var canAdvance: Bool {
        switch step {
        case .role: role != nil
        case .hero: heroID != nil
        case .map: mapID != nil
        case .result: result != nil
        case .focus: focus != nil
        case .death: deathCause != nil
        case .tilt: false
        }
    }

    public var canGoBack: Bool { step != .role }

    public mutating func advance() {
        guard canAdvance, let next = Step(rawValue: step.rawValue + 1) else { return }
        step = next
    }

    public mutating func goBack() {
        guard let previous = Step(rawValue: step.rawValue - 1) else { return }
        step = previous
    }

    public mutating func choose(role newRole: Role) {
        if newRole != role { heroID = nil }
        role = newRole
        advance()
    }

    public mutating func choose(heroID id: String) {
        heroID = id
        advance()
    }

    public mutating func choose(mapID id: String) {
        mapID = id
        advance()
    }

    public mutating func choose(result newResult: GameResult) {
        result = newResult
        advance()
    }

    public mutating func choose(focus value: Int) {
        focus = value
        advance()
    }

    public mutating func choose(deathCause cause: DeathCause) {
        deathCause = cause
        advance()
    }

    public mutating func choose(tilt value: Int) {
        tilt = value
    }

    public func record(date: Date, focusCardID: String?) -> GameRecord? {
        guard let role, let heroID, let mapID, let result, let focus, let deathCause, let tilt else { return nil }
        return GameRecord(date: date, role: role, heroID: heroID, mapID: mapID, result: result, focus: focus, focusCardID: focusCardID, deathCause: deathCause, tilt: tilt)
    }
}
