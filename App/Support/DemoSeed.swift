import Foundation
import OWCoachKit
import SwiftData

enum DemoSeed {
    @MainActor
    static func seed(into context: ModelContext) {
        let settings = AppSettings.current(in: context)
        settings.defaultRole = .damage
        settings.poolHeroIDs = ["torbjorn", "zarya", "winston"]
        let focus = FocusPlan.current(in: context)
        focus.weekHeroIDs = ["torbjorn", "zarya"]
        focus.activeCardID = "cover"
        let causes: [DeathCause] = [.open, .open, .tooFar, .fair, .open, .surprised, .barelyDied, .open, .timing, .fair, .open, .isolated]
        let calendar = Calendar.current
        for (index, cause) in causes.enumerated() {
            let day = calendar.date(byAdding: .day, value: -(index / 3), to: .now) ?? .now
            let date = calendar.date(byAdding: .minute, value: -(index % 3) * 25, to: day) ?? day
            let record = GameRecord(
                date: date,
                role: index % 4 == 0 ? .tank : .damage,
                heroID: index % 4 == 0 ? "zarya" : "torbjorn",
                mapID: ["kings-row", "busan", "paraiso", "havana"][index % 4],
                result: index % 3 == 0 ? .loss : .win,
                focus: 2 + index % 4,
                focusCardID: "cover",
                deathCause: cause,
                tilt: 1 + index % 4
            )
            context.insert(GameEntry(record: record))
        }
        let review = VODReview()
        review.heroID = "torbjorn"
        review.mapID = "kings-row"
        review.replayCode = "7Q2KXA"
        context.insert(review)
        context.insert(Finding(reviewKey: review.key, cardID: "cover", text: "Nach dem Kill nach vorn ins Offene gelaufen, von der Widow erwischt.", moment: "R2 3:40", starred: true))
        context.insert(Finding(reviewKey: review.key, cardID: "torb-turret-crossfire", text: "Turret direkt neben mir, beide in einem Ult erwischt.", moment: "R3 1:10", starred: false))
        try? context.save()
    }
}
