import Foundation
import Testing
@testable import OWCoachKit

struct ContentLibraryTests {
    static func fixture() throws -> ContentLibrary {
        let url = try #require(Bundle.module.url(forResource: "Content", withExtension: nil, subdirectory: "Fixtures"))
        return try ContentLibrary.load(from: url)
    }

    @Test func loadsAllThreeKinds() throws {
        let lib = try Self.fixture()
        #expect(lib.basics.map(\.id) == ["cover"])
        #expect(lib.heroes.map(\.id) == ["testhero"])
        #expect(lib.maps.count == 3)
    }

    @Test func rolePointsOverrideGeneralPoints() throws {
        let cover = try #require(try Self.fixture().card("cover"))
        #expect(cover.points(for: .damage) == ["DPS eins"])
        #expect(cover.points(for: .tank) == ["Allgemein eins", "Allgemein zwei"])
        #expect(cover.points(for: nil) == ["Allgemein eins", "Allgemein zwei"])
    }

    @Test func findsHeroCardsAndOwner() throws {
        let lib = try Self.fixture()
        #expect(lib.card("testhero-a")?.title == "A")
        #expect(lib.heroOwning(cardID: "testhero-a")?.id == "testhero")
        #expect(lib.heroOwning(cardID: "cover") == nil)
        #expect(lib.heroes(for: .tank).map(\.id) == ["testhero"])
        #expect(lib.heroes(for: .support).isEmpty)
    }

    @Test func unknownIDsReturnNil() throws {
        let lib = try Self.fixture()
        #expect(lib.hero("gone") == nil)
        #expect(lib.card("gone") == nil)
        #expect(lib.map("gone") == nil)
    }

    @Test func assetNamesFollowConvention() throws {
        let lib = try Self.fixture()
        #expect(lib.heroes[0].iconAsset == "hero-testhero")
        #expect(lib.maps[0].imageAsset == "map-paraiso")
    }

    @Test func missingDirectoryThrows() {
        #expect(throws: (any Error).self) {
            try ContentLibrary.load(from: URL(fileURLWithPath: "/nonexistent"))
        }
    }
}
