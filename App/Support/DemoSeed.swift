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
        try? context.save()
    }
}
