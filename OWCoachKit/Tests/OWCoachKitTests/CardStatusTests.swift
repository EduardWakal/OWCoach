import Testing
@testable import OWCoachKit

struct CardStatusTests {
    @Test func openActiveMastered() {
        #expect(CardStatus.of("cover", active: nil, mastered: []) == .open)
        #expect(CardStatus.of("cover", active: "cover", mastered: []) == .active)
        #expect(CardStatus.of("cover", active: "threat", mastered: ["cover"]) == .mastered)
    }

    @Test func activeWinsOverMastered() {
        #expect(CardStatus.of("cover", active: "cover", mastered: ["cover"]) == .active)
    }
}
