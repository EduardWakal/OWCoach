import Foundation

public enum Role: String, Codable, CaseIterable, Sendable, Identifiable {
    case tank, damage, support

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .tank: "Tank"
        case .damage: "DPS"
        case .support: "Support"
        }
    }
}

public enum GameResult: String, Codable, CaseIterable, Sendable, Identifiable {
    case win, loss, draw

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .win: "Sieg"
        case .loss: "Niederlage"
        case .draw: "Unentschieden"
        }
    }
}

public enum DeathCause: String, Codable, CaseIterable, Sendable, Identifiable {
    case open, tooFar, isolated, surprised, noExit, timing, fair, barelyDied

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .open: "Offen"
        case .tooFar: "Zu weit vorn"
        case .isolated: "Allein"
        case .surprised: "Überrascht"
        case .noExit: "Kein Ausweg"
        case .timing: "Timing"
        case .fair: "Fair"
        case .barelyDied: "Kaum gestorben"
        }
    }

    public var emoji: String {
        switch self {
        case .open: "🧱"
        case .tooFar: "🏃"
        case .isolated: "🏝️"
        case .surprised: "👀"
        case .noExit: "🚪"
        case .timing: "⏱️"
        case .fair: "🎲"
        case .barelyDied: "✅"
        }
    }

    public var basicCardID: String? {
        switch self {
        case .open: "cover"
        case .tooFar: "go-back"
        case .isolated: "position-team"
        case .surprised: "threat"
        case .noExit: "escape"
        case .timing: "timing"
        case .fair, .barelyDied: nil
        }
    }
}

public enum MapMode: String, Codable, CaseIterable, Sendable, Identifiable {
    case control, escort, flashpoint, hybrid, push

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .control: "Control"
        case .escort: "Escort"
        case .flashpoint: "Flashpoint"
        case .hybrid: "Hybrid"
        case .push: "Push"
        }
    }
}
