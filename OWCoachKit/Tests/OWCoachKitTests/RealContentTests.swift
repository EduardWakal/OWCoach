import Foundation
import Testing
@testable import OWCoachKit

struct RealContentTests {
    static var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    static func repoContent() throws -> ContentLibrary {
        try ContentLibrary.load(from: repoRoot.appending(path: "Content"))
    }

    @Test func basicsMatchDeathCauses() throws {
        let lib = try Self.repoContent()
        #expect(lib.basics.map(\.id) == ["cover", "slicing", "go-back", "position-team", "threat", "escape", "timing"])
        for cause in DeathCause.allCases {
            if let id = cause.basicCardID { #expect(lib.card(id) != nil, "missing card \(id)") }
        }
    }

    @Test func startHeroesExist() throws {
        let lib = try Self.repoContent()
        #expect(Set(lib.heroes.map(\.id)) == ["torbjorn", "juno", "domina", "winston", "zarya"])
        #expect(lib.hero("torbjorn")?.path.count == 5)
        #expect(lib.hero("zarya")?.role == .tank)
        #expect(lib.hero("juno")?.role == .support)
    }

    @Test func everyCardFollowsTheShortFormat() throws {
        let lib = try Self.repoContent()
        let cards = lib.basics + lib.heroes.flatMap(\.path)
        for card in cards {
            #expect(card.question.hasSuffix("?"), "\(card.id) question")
            #expect((1...3).contains(card.points.count), "\(card.id) points")
            for variant in (card.rolePoints ?? [:]).values {
                #expect((1...3).contains(variant.count), "\(card.id) variant")
            }
            #expect(card.videos.count <= 5, "\(card.id) videos")
        }
    }

    @Test func idsAreUnique() throws {
        let lib = try Self.repoContent()
        let ids = lib.basics.map(\.id) + lib.heroes.flatMap(\.path).map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func rolePointKeysAreRoles() throws {
        let lib = try Self.repoContent()
        let keys = (lib.basics + lib.heroes.flatMap(\.path)).flatMap { ($0.rolePoints ?? [:]).keys }
        for key in keys { #expect(Role(rawValue: key) != nil, "bad role key \(key)") }
    }
}
