import Testing
@testable import OWCoachKit

struct DomainTests {
    @Test func everyActionableCauseMapsToABasicCard() {
        let mapped = DeathCause.allCases.compactMap(\.basicCardID)
        #expect(mapped == ["cover", "go-back", "position-team", "threat", "escape", "timing"])
        #expect(DeathCause.fair.basicCardID == nil)
        #expect(DeathCause.barelyDied.basicCardID == nil)
    }

    @Test func rawValuesAreStable() {
        #expect(Role.allCases.map(\.rawValue) == ["tank", "damage", "support"])
        #expect(GameResult.allCases.map(\.rawValue) == ["win", "loss", "draw"])
        #expect(MapMode.allCases.map(\.rawValue) == ["control", "escort", "flashpoint", "hybrid", "push"])
    }

    @Test func labelsAreGerman() {
        #expect(Role.damage.label == "DPS")
        #expect(GameResult.draw.label == "Unentschieden")
        #expect(DeathCause.open.label == "Offen")
    }
}
