import Foundation

public enum MapSearch {
    public static func filter(_ maps: [GameMap], query: String) -> [GameMap] {
        let needle = normalized(query)
        guard !needle.isEmpty else { return maps }
        return maps.filter { normalized($0.name).contains(needle) }
    }

    static func normalized(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .filter { $0.isLetter || $0.isNumber || $0 == " " }
            .trimmingCharacters(in: .whitespaces)
    }
}
