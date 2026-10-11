import Foundation

public enum SingletonMerge {
    public static func union(_ lists: [[String]]) -> [String] {
        var seen = Set<String>()
        return lists.flatMap { $0 }.filter { seen.insert($0).inserted }
    }

    public static func first<T>(_ values: [T?]) -> T? {
        values.lazy.compactMap { $0 }.first
    }

    public static func dismissed(_ maps: [[String: Int]]) -> [String: Int] {
        maps.reduce(into: [:]) { merged, map in
            merged.merge(map) { max($0, $1) }
        }
    }
}
