import Foundation

public struct ContentLibrary: Sendable {
    public let basics: [Card]
    public let heroes: [Hero]
    public let maps: [GameMap]

    public static let empty = ContentLibrary(basics: [], heroes: [], maps: [])

    public init(basics: [Card], heroes: [Hero], maps: [GameMap]) {
        self.basics = basics
        self.heroes = heroes
        self.maps = maps
    }

    public static func load(from directory: URL) throws -> ContentLibrary {
        let decoder = JSONDecoder()
        let basics = try decoder.decode([Card].self, from: Data(contentsOf: directory.appending(path: "basics.json")))
        let heroFiles = try FileManager.default
            .contentsOfDirectory(at: directory.appending(path: "heroes"), includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        let heroes = try heroFiles.map { try decoder.decode(Hero.self, from: Data(contentsOf: $0)) }
        let maps = try decoder.decode([GameMap].self, from: Data(contentsOf: directory.appending(path: "maps.json")))
        return ContentLibrary(basics: basics, heroes: heroes, maps: maps)
    }

    public func hero(_ id: String) -> Hero? {
        heroes.first { $0.id == id }
    }

    public func map(_ id: String) -> GameMap? {
        maps.first { $0.id == id }
    }

    public func card(_ id: String) -> Card? {
        basics.first { $0.id == id } ?? heroes.lazy.flatMap(\.path).first { $0.id == id }
    }

    public func heroes(for role: Role) -> [Hero] {
        heroes.filter { $0.role == role }
    }

    public func heroOwning(cardID: String) -> Hero? {
        heroes.first { hero in hero.path.contains { $0.id == cardID } }
    }
}
