import Foundation
import OWCoachKit
import SwiftData

@Model
final class GameEntry {
    var date: Date = Date()
    var roleRaw: String = Role.damage.rawValue
    var heroID: String = ""
    var mapID: String = ""
    var resultRaw: String = GameResult.win.rawValue
    var focus: Int = 3
    var focusCardID: String?
    var deathCauseRaw: String = DeathCause.fair.rawValue
    var tilt: Int = 2

    init(record: GameRecord) {
        date = record.date
        roleRaw = record.role.rawValue
        heroID = record.heroID
        mapID = record.mapID
        resultRaw = record.result.rawValue
        focus = record.focus
        focusCardID = record.focusCardID
        deathCauseRaw = record.deathCause.rawValue
        tilt = record.tilt
    }

    var record: GameRecord {
        GameRecord(
            date: date,
            role: Role(rawValue: roleRaw) ?? .damage,
            heroID: heroID,
            mapID: mapID,
            result: GameResult(rawValue: resultRaw) ?? .loss,
            focus: focus,
            focusCardID: focusCardID,
            deathCause: DeathCause(rawValue: deathCauseRaw) ?? .fair,
            tilt: tilt
        )
    }
}
