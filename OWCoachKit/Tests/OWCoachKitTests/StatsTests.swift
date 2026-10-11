import Foundation
import Testing
@testable import OWCoachKit

func game(
    _ dateString: String,
    result: GameResult = .win,
    focus: Int = 3,
    card: String? = "cover",
    cause: DeathCause = .fair,
    hero: String = "torbjorn"
) -> GameRecord {
    let formatter = ISO8601DateFormatter()
    formatter.timeZone = TimeZone(identifier: "Europe/Berlin")
    formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime, .withDashSeparatorInDate]
    let date = formatter.date(from: dateString)!
    return GameRecord(date: date, role: .damage, heroID: hero, mapID: "busan", result: result, focus: focus, focusCardID: card, deathCause: cause, tilt: 2)
}

var berlin: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Europe/Berlin")!
    return calendar
}

struct StatsTests {
    @Test func winRateCountsDrawsAsGames() {
        let games = [game("2026-10-11T20:00:00"), game("2026-10-11T20:30:00", result: .loss), game("2026-10-11T21:00:00", result: .draw), game("2026-10-11T21:30:00")]
        #expect(Stats.winRate(games) == 0.5)
        #expect(Stats.winRate([]) == nil)
    }

    @Test func focusAverage() {
        let games = [game("2026-10-11T20:00:00", focus: 2), game("2026-10-11T21:00:00", focus: 5)]
        #expect(Stats.focusAverage(games) == 3.5)
        #expect(Stats.focusAverage([]) == nil)
    }

    @Test func topDeathCauseIgnoresFairAndBarelyDied() {
        let games = [
            game("2026-10-11T20:00:00", cause: .fair),
            game("2026-10-11T20:10:00", cause: .fair),
            game("2026-10-11T20:20:00", cause: .barelyDied),
            game("2026-10-11T20:30:00", cause: .surprised),
        ]
        #expect(Stats.topDeathCause(games) == .surprised)
        #expect(Stats.topDeathCause([game("2026-10-11T20:00:00", cause: .fair)]) == nil)
    }

    @Test func topDeathCauseTieGoesToEarlierCase() {
        let games = [game("2026-10-11T20:00:00", cause: .timing), game("2026-10-11T20:10:00", cause: .open)]
        #expect(Stats.topDeathCause(games) == .open)
    }

    @Test func recentIncludesTodayAndSixDaysBack() {
        let now = game("2026-10-11T22:00:00").date
        let games = [game("2026-10-05T00:05:00"), game("2026-10-04T23:55:00"), game("2026-10-11T21:00:00")]
        let recent = Stats.recent(games, days: 7, now: now, calendar: berlin)
        #expect(recent.count == 2)
    }

    @Test func playDaysSplitAtMidnight() {
        let days = Stats.playDays([game("2026-10-11T00:01:00"), game("2026-10-10T23:59:00"), game("2026-10-10T20:00:00")], calendar: berlin)
        #expect(days.count == 2)
        #expect(days[0].games.count == 2)
        #expect(days[1].games.count == 1)
        #expect(days[0].day < days[1].day)
    }
}
