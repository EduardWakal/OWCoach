import Testing
@testable import OWCoachKit

struct MapSearchTests {
    let maps = [
        GameMap(id: "paraiso", name: "Paraíso", mode: .hybrid),
        GameMap(id: "kings-row", name: "King's Row", mode: .hybrid),
        GameMap(id: "busan", name: "Busan", mode: .control),
    ]

    @Test func emptyQueryReturnsAll() {
        #expect(MapSearch.filter(maps, query: "  ").count == 3)
    }

    @Test func ignoresCaseAndDiacritics() {
        #expect(MapSearch.filter(maps, query: "paraiso").map(\.id) == ["paraiso"])
        #expect(MapSearch.filter(maps, query: "BUS").map(\.id) == ["busan"])
    }

    @Test func ignoresApostrophes() {
        #expect(MapSearch.filter(maps, query: "kings").map(\.id) == ["kings-row"])
    }
}
