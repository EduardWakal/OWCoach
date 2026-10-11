import Foundation
import Testing
@testable import OWCoachKit

var berlinMonday: Calendar {
    var calendar = berlin
    calendar.firstWeekday = 2
    calendar.minimumDaysInFirstWeek = 4
    return calendar
}

struct StatsBreakdownTests {
    @Test func rangeFilters() {
        let now = game("2026-10-11T22:00:00").date
        let games = [game("2026-10-11T20:00:00"), game("2026-10-01T20:00:00"), game("2026-08-01T20:00:00")]
        #expect(StatsRange.week.filter(games, now: now, calendar: berlin).count == 1)
        #expect(StatsRange.month.filter(games, now: now, calendar: berlin).count == 2)
        #expect(StatsRange.all.filter(games, now: now, calendar: berlin).count == 3)
    }

    @Test func byHeroSortsByGames() {
        let games = [
            game("2026-10-11T20:00:00", result: .win, focus: 4, hero: "zarya"),
            game("2026-10-11T20:10:00", result: .loss, focus: 2, hero: "zarya"),
            game("2026-10-11T20:20:00", result: .win, focus: 5, hero: "torbjorn"),
        ]
        let stats = Stats.byHero(games)
        #expect(stats.map(\.id) == ["zarya", "torbjorn"])
        #expect(stats[0] == GroupStat(id: "zarya", games: 2, winRate: 0.5, focusAverage: 3))
    }

    @Test func dailyValuesPerPlayDay() {
        let games = [game("2026-10-10T20:00:00", result: .win, focus: 2), game("2026-10-10T21:00:00", result: .loss, focus: 4), game("2026-10-11T20:00:00", result: .win, focus: 5)]
        #expect(Stats.dailyFocus(games, calendar: berlin).map(\.value) == [3, 5])
        #expect(Stats.dailyWinRate(games, calendar: berlin).map(\.value) == [0.5, 1])
    }

    @Test func weeklyCausesSkipBarelyDied() {
        let games = [
            game("2026-10-05T20:00:00", cause: .open),
            game("2026-10-06T20:00:00", cause: .open),
            game("2026-10-07T20:00:00", cause: .barelyDied),
            game("2026-10-12T20:00:00", cause: .surprised),
        ]
        let weeks = Stats.weeklyCauses(games, calendar: berlinMonday)
        #expect(weeks.map(\.cause) == [.open, .surprised])
        #expect(weeks.map(\.count) == [2, 1])
        #expect(weeks[0].weekStart < weeks[1].weekStart)
    }

    @Test func weeksSpanYearEnd() {
        let games = [game("2026-12-28T20:00:00", cause: .open), game("2027-01-02T20:00:00", cause: .open)]
        #expect(Stats.weeklyCauses(games, calendar: berlinMonday).map(\.count) == [2])
    }

    @Test func firstUseOfCard() {
        let games = [game("2026-10-11T20:00:00", card: "cover"), game("2026-10-09T20:00:00", card: "cover"), game("2026-10-01T20:00:00", card: "threat")]
        #expect(Stats.firstUse(of: "cover", in: games) == game("2026-10-09T20:00:00").date)
        #expect(Stats.firstUse(of: "escape", in: games) == nil)
    }

    @Test func emptyInputGivesEmptyBreakdowns() {
        #expect(Stats.byHero([]).isEmpty)
        #expect(Stats.byMap([]).isEmpty)
        #expect(Stats.dailyFocus([], calendar: berlin).isEmpty)
        #expect(Stats.weeklyCauses([], calendar: berlin).isEmpty)
    }
}
