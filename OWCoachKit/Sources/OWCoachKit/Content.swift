import Foundation

public struct VideoLink: Codable, Hashable, Sendable {
    public let label: String
    public let url: URL

    public init(label: String, url: URL) {
        self.label = label
        self.url = url
    }
}

public struct Card: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let question: String
    public let points: [String]
    public let rolePoints: [String: [String]]?
    public let videos: [VideoLink]

    public init(id: String, title: String, question: String, points: [String], rolePoints: [String: [String]]? = nil, videos: [VideoLink] = []) {
        self.id = id
        self.title = title
        self.question = question
        self.points = points
        self.rolePoints = rolePoints
        self.videos = videos
    }

    public func points(for role: Role?) -> [String] {
        if let role, let variant = rolePoints?[role.rawValue] { return variant }
        return points
    }
}

public struct GuideRule: Codable, Hashable, Sendable {
    public let text: String
    public let videos: [VideoLink]

    public init(text: String, videos: [VideoLink] = []) {
        self.text = text
        self.videos = videos
    }
}

public struct GuideSection: Codable, Hashable, Sendable, Identifiable {
    public let title: String
    public let rules: [GuideRule]

    public var id: String { title }

    public init(title: String, rules: [GuideRule]) {
        self.title = title
        self.rules = rules
    }
}

public struct Hero: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let role: Role
    public let guide: [GuideSection]
    public let path: [Card]

    public var iconAsset: String { "hero-\(id)" }

    public init(id: String, name: String, role: Role, guide: [GuideSection] = [], path: [Card] = []) {
        self.id = id
        self.name = name
        self.role = role
        self.guide = guide
        self.path = path
    }
}

public struct GameMap: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let mode: MapMode

    public var imageAsset: String { "map-\(id)" }

    public init(id: String, name: String, mode: MapMode) {
        self.id = id
        self.name = name
        self.mode = mode
    }
}
