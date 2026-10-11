import Foundation
import OWCoachKit
import SwiftUI

extension EnvironmentValues {
    @Entry var content: ContentLibrary = .empty
}

enum BundledContent {
    static func load() -> ContentLibrary {
        guard let url = Bundle.main.url(forResource: "Content", withExtension: nil),
              let library = try? ContentLibrary.load(from: url) else { return .empty }
        return library
    }
}
