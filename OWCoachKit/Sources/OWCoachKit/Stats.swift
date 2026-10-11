import Foundation

public struct PlayDay: Hashable, Sendable {
    public let day: Date
    public let games: [GameRecord]
}

public enum Stats {
    public static func recent(_ games: [GameRecord], days: Int, now: Date, calendar: Calendar = .current) -> [GameRecord] {
        guard let start = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: now)) else { return [] }
        return games.filter { $0.date >= start && $0.date <= now }
    }

    public static func winRate(_ games: [GameRecord]) -> Double? {
        guard !games.isEmpty else { return nil }
        return Double(games.filter { $0.result == .win }.count) / Double(games.count)
    }

    public static func focusAverage(_ games: [GameRecord]) -> Double? {
        guard !games.isEmpty else { return nil }
        return Double(games.map(\.focus).reduce(0, +)) / Double(games.count)
    }

    public static func topDeathCause(_ games: [GameRecord]) -> DeathCause? {
        var best: (cause: DeathCause, count: Int)?
        for cause in DeathCause.allCases where cause.basicCardID != nil {
            let count = games.filter { $0.deathCause == cause }.count
            if count > 0, count > (best?.count ?? 0) { best = (cause, count) }
        }
        return best?.cause
    }

    public static func playDays(_ games: [GameRecord], calendar: Calendar = .current) -> [PlayDay] {
        Dictionary(grouping: games) { calendar.startOfDay(for: $0.date) }
            .map { PlayDay(day: $0.key, games: $0.value.sorted { $0.date < $1.date }) }
            .sorted { $0.day < $1.day }
    }
}
