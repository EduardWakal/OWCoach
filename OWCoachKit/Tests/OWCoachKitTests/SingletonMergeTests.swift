import Testing
@testable import OWCoachKit

struct SingletonMergeTests {
    @Test func unionKeepsOldestOrderAndDropsDuplicates() {
        #expect(SingletonMerge.union([["zarya", "torbjorn"], ["torbjorn", "juno"], []]) == ["zarya", "torbjorn", "juno"])
    }

    @Test func firstValueSkipsNil() {
        #expect(SingletonMerge.first([nil, "cover", "threat"]) == "cover")
        #expect(SingletonMerge.first([String?]([nil, nil])) == nil)
    }

    @Test func dismissedKeepsHighestGameCountPerKey() {
        let merged = SingletonMerge.dismissed([["mastered:cover": 4, "switch:threat": 9], ["mastered:cover": 7]])
        #expect(merged == ["mastered:cover": 7, "switch:threat": 9])
    }
}
