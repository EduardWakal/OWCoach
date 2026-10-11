import Foundation

public struct GameRecord: Hashable, Sendable {
    public var date: Date
    public var role: Role
    public var heroID: String
    public var mapID: String
    public var result: GameResult
    public var focus: Int
    public var focusCardID: String?
    public var deathCause: DeathCause
    public var tilt: Int

    public init(date: Date, role: Role, heroID: String, mapID: String, result: GameResult, focus: Int, focusCardID: String?, deathCause: DeathCause, tilt: Int) {
        self.date = date
        self.role = role
        self.heroID = heroID
        self.mapID = mapID
        self.result = result
        self.focus = focus
        self.focusCardID = focusCardID
        self.deathCause = deathCause
        self.tilt = tilt
    }
}
