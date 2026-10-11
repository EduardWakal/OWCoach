import Foundation
import Testing
@testable import OWCoachKit

struct SuggestionTests {
    func input(_ games: [GameRecord], active: String? = "cover", mastered: Set<String> = [], dismissed: [String: Int] = [:]) -> SuggestionInput {
        SuggestionInput(games: games, activeCardID: active, masteredCardIDs: mastered, dismissedAtGameCount: dismissed)
    }

    var threeGoodDays: [GameRecord] {
        [game("2026-10-08T20:00:00", focus: 4), game("2026-10-09T20:00:00", focus: 5), game("2026-10-10T20:00:00", focus: 4)]
    }

    @Test func masteredAfterThreeDaysOfFourPlus() {
        #expect(SuggestionEngine.suggestion(for: input(threeGoodDays), calendar: berlin) == .cardMastered(cardID: "cover"))
    }

    @Test func notMasteredWithOnlyTwoDays() {
        #expect(SuggestionEngine.suggestion(for: input(Array(threeGoodDays.prefix(2))), calendar: berlin) == nil)
    }

    @Test func notMasteredWhenOneDayAveragesBelowFour() {
        var games = threeGoodDays
        games.append(game("2026-10-10T21:00:00", focus: 2))
        #expect(SuggestionEngine.suggestion(for: input(games), calendar: berlin) == nil)
    }

    @Test func masteryIgnoresGamesWithOtherCard() {
        var games = threeGoodDays
        games.append(game("2026-10-10T21:00:00", focus: 1, card: "threat"))
        #expect(SuggestionEngine.suggestion(for: input(games), calendar: berlin) == .cardMastered(cardID: "cover"))
    }

    @Test func switchFocusAtExactlyFortyPercent() {
        let games = (0..<10).map { i in
            game("2026-10-10T20:\(String(format: "%02d", i)):00", focus: 2, cause: i < 4 ? .open : .fair)
        }
        #expect(SuggestionEngine.suggestion(for: input(games, active: "threat"), calendar: berlin) == .switchFocus(cause: .open, cardID: "cover"))
    }

    @Test func noSwitchBelowFourGames() {
        let games = (0..<3).map { i in game("2026-10-10T20:0\(i):00", focus: 2, cause: .open) }
        #expect(SuggestionEngine.suggestion(for: input(games, active: "threat"), calendar: berlin) == nil)
    }

    @Test func noSwitchToActiveOrMasteredCard() {
        let games = (0..<4).map { i in game("2026-10-10T20:0\(i):00", focus: 2, cause: .open) }
        #expect(SuggestionEngine.suggestion(for: input(games, active: "cover"), calendar: berlin) == nil)
        #expect(SuggestionEngine.suggestion(for: input(games, active: "threat", mastered: ["cover"]), calendar: berlin) == nil)
    }

    @Test func switchUsesOnlyLastTenGames() {
        let old = (0..<10).map { i in game("2026-10-01T20:0\(i):00", focus: 2, cause: .open) }
        let new = (0..<10).map { i in game("2026-10-10T20:0\(i):00", focus: 2, cause: .fair) }
        #expect(SuggestionEngine.suggestion(for: input(old + new, active: "threat"), calendar: berlin) == nil)
    }

    @Test func moveOnAfterTenPlayDays() {
        let games = (1...10).map { d in game("2026-09-\(String(format: "%02d", d))T20:00:00", focus: 2, cause: .fair) }
        #expect(SuggestionEngine.suggestion(for: input(games), calendar: berlin) == .moveOn(cardID: "cover"))
    }

    @Test func masteredBeatsSwitch() {
        var games = threeGoodDays
        games += (0..<4).map { i in game("2026-10-10T21:0\(i):00", focus: 4, card: "cover", cause: .surprised) }
        #expect(SuggestionEngine.suggestion(for: input(games), calendar: berlin) == .cardMastered(cardID: "cover"))
    }

    @Test func dismissedSuggestionWaitsThreeGames() {
        let games = threeGoodDays
        let dismissedNow = input(games, dismissed: ["mastered:cover": games.count])
        #expect(SuggestionEngine.suggestion(for: dismissedNow, calendar: berlin) == nil)
        let later = games + [game("2026-10-10T21:00:00", focus: 5), game("2026-10-10T21:10:00", focus: 5), game("2026-10-10T21:20:00", focus: 5)]
        let dismissedEarlier = input(later, dismissed: ["mastered:cover": games.count])
        #expect(SuggestionEngine.suggestion(for: dismissedEarlier, calendar: berlin) == .cardMastered(cardID: "cover"))
    }

    @Test func noActiveCardMeansOnlySwitchCanFire() {
        #expect(SuggestionEngine.suggestion(for: input(threeGoodDays, active: nil), calendar: berlin) == nil)
    }

    @Test func keys() {
        #expect(Suggestion.cardMastered(cardID: "cover").key == "mastered:cover")
        #expect(Suggestion.switchFocus(cause: .open, cardID: "cover").key == "switch:cover")
        #expect(Suggestion.moveOn(cardID: "cover").key == "moveOn:cover")
    }
}
