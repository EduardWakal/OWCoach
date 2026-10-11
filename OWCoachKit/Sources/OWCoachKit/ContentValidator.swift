import Foundation

public enum ContentValidator {
    public static func missingAssets(in library: ContentLibrary, assetCatalog: URL) -> [String] {
        let names = library.heroes.map(\.iconAsset) + library.maps.map(\.imageAsset)
        let existing = imageSetNames(under: assetCatalog)
        return names.filter { !existing.contains($0) }
    }

    static func imageSetNames(under catalog: URL) -> Set<String> {
        guard let enumerator = FileManager.default.enumerator(at: catalog, includingPropertiesForKeys: nil) else { return [] }
        var names = Set<String>()
        for case let url as URL in enumerator where url.pathExtension == "imageset" {
            let hasImage = (try? FileManager.default.contentsOfDirectory(atPath: url.path))?.contains { $0.hasSuffix(".png") || $0.hasSuffix(".jpg") } ?? false
            if hasImage { names.insert(url.deletingPathExtension().lastPathComponent) }
        }
        return names
    }
}
