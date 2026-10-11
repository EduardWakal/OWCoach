import Foundation
import Testing
@testable import OWCoachKit

struct LearningsTests {
    func finding(_ card: String, starred: Bool = false, minutesAgo: Double = 0) -> FindingRecord {
        FindingRecord(key: UUID().uuidString, reviewKey: "r1", cardID: card, text: "t", moment: nil, starred: starred, date: Date(timeIntervalSince1970: 10_000 - minutesAgo * 60))
    }

    @Test func forCardPutsStarredFirstThenNewest() {
        let old = finding("cover", minutesAgo: 30)
        let new = finding("cover", minutesAgo: 1)
        let star = finding("cover", starred: true, minutesAgo: 60)
        let other = finding("threat")
        #expect(Learnings.forCard("cover", in: [old, other, new, star]) == [star, new, old])
    }

    @Test func starredOnlyReturnsStarred() {
        let star = finding("cover", starred: true)
        #expect(Learnings.starred(for: "cover", in: [finding("cover"), star]) == [star])
    }

    @Test func groupedSortsByCountThenID() {
        let groups = Learnings.grouped([finding("threat"), finding("cover"), finding("threat"), finding("escape")])
        #expect(groups.map(\.cardID) == ["threat", "cover", "escape"])
        #expect(groups[0].findings.count == 2)
    }

    @Test func groupsKeepUnknownCards() {
        #expect(Learnings.grouped([finding("gone-card")]).map(\.cardID) == ["gone-card"])
    }
}
