import Foundation

public enum StatsRange: String, CaseIterable, Sendable, Identifiable {
    case week, month, all

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .week: "7 Tage"
        case .month: "30 Tage"
        case .all: "Alles"
        }
    }

    public func filter(_ games: [GameRecord], now: Date, calendar: Calendar = .current) -> [GameRecord] {
        switch self {
        case .week: Stats.recent(games, days: 7, now: now, calendar: calendar)
        case .month: Stats.recent(games, days: 30, now: now, calendar: calendar)
        case .all: games
        }
    }
}

public struct GroupStat: Hashable, Sendable, Identifiable {
    public let id: String
    public let games: Int
    public let winRate: Double
    public let focusAverage: Double
}

public struct DayValue: Hashable, Sendable {
    public let day: Date
    public let value: Double
}

public struct WeekCause: Hashable, Sendable {
    public let weekStart: Date
    public let cause: DeathCause
    public let count: Int
}

extension Stats {
    public static func byHero(_ games: [GameRecord]) -> [GroupStat] {
        group(games, by: \.heroID)
    }

    public static func byMap(_ games: [GameRecord]) -> [GroupStat] {
        group(games, by: \.mapID)
    }

    public static func dailyFocus(_ games: [GameRecord], calendar: Calendar = .current) -> [DayValue] {
        playDays(games, calendar: calendar).compactMap { day in
            focusAverage(day.games).map { DayValue(day: day.day, value: $0) }
        }
    }

    public static func dailyWinRate(_ games: [GameRecord], calendar: Calendar = .current) -> [DayValue] {
        playDays(games, calendar: calendar).compactMap { day in
            winRate(day.games).map { DayValue(day: day.day, value: $0) }
        }
    }

    public static func weeklyCauses(_ games: [GameRecord], calendar: Calendar = .current) -> [WeekCause] {
        let counted = games.filter { $0.deathCause != .barelyDied }
        let byWeek = Dictionary(grouping: counted) { calendar.dateInterval(of: .weekOfYear, for: $0.date)?.start ?? calendar.startOfDay(for: $0.date) }
        return byWeek.keys.sorted().flatMap { week in
            let weekGames = byWeek[week] ?? []
            return DeathCause.allCases.compactMap { cause in
                let count = weekGames.filter { $0.deathCause == cause }.count
                return count > 0 ? WeekCause(weekStart: week, cause: cause, count: count) : nil
            }
        }
    }

    public static func firstUse(of cardID: String, in games: [GameRecord]) -> Date? {
        games.filter { $0.focusCardID == cardID }.map(\.date).min()
    }

    static func group(_ games: [GameRecord], by key: KeyPath<GameRecord, String>) -> [GroupStat] {
        Dictionary(grouping: games) { $0[keyPath: key] }
            .map { GroupStat(id: $0.key, games: $0.value.count, winRate: winRate($0.value) ?? 0, focusAverage: focusAverage($0.value) ?? 0) }
            .sorted { ($0.games, $1.id) > ($1.games, $0.id) }
    }
}
