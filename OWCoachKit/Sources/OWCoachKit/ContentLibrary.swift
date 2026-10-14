import Foundation

public struct ContentLibrary: Sendable {
    public let basics: [Card]
    public let roleCards: [Role: [Card]]
    public let heroes: [Hero]
    public let maps: [GameMap]

    public static let empty = ContentLibrary(basics: [], heroes: [], maps: [])

    public init(basics: [Card], roleCards: [Role: [Card]] = [:], heroes: [Hero], maps: [GameMap]) {
        self.basics = basics
        self.roleCards = roleCards
        self.heroes = heroes
        self.maps = maps
    }

    public static func load(from directory: URL) throws -> ContentLibrary {
        let decoder = JSONDecoder()
        let basics = try decoder.decode([Card].self, from: Data(contentsOf: directory.appending(path: "basics.json")))
        let rawRoleCards = try decoder.decode([String: [Card]].self, from: Data(contentsOf: directory.appending(path: "roles.json")))
        let roleCards = Dictionary(uniqueKeysWithValues: rawRoleCards.compactMap { key, cards in Role(rawValue: key).map { ($0, cards) } })
        let heroFiles = try FileManager.default
            .contentsOfDirectory(at: directory.appending(path: "heroes"), includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        let heroes = try heroFiles.map { try decoder.decode(Hero.self, from: Data(contentsOf: $0)) }
        let maps = try decoder.decode([GameMap].self, from: Data(contentsOf: directory.appending(path: "maps.json")))
        return ContentLibrary(basics: basics, roleCards: roleCards, heroes: heroes, maps: maps)
    }

    public func hero(_ id: String) -> Hero? {
        heroes.first { $0.id == id }
    }

    public func map(_ id: String) -> GameMap? {
        maps.first { $0.id == id }
    }

    public func card(_ id: String) -> Card? {
        basics.first { $0.id == id }
            ?? roleCards.values.lazy.flatMap { $0 }.first { $0.id == id }
            ?? heroes.lazy.flatMap(\.path).first { $0.id == id }
    }

    public func cards(for role: Role) -> [Card] {
        roleCards[role] ?? []
    }

    public func roleOwning(cardID: String) -> Role? {
        Role.allCases.first { role in cards(for: role).contains { $0.id == cardID } }
    }

    public func heroes(for role: Role) -> [Hero] {
        heroes.filter { $0.role == role }
    }

    public func heroOwning(cardID: String) -> Hero? {
        heroes.first { hero in hero.path.contains { $0.id == cardID } }
    }
}
