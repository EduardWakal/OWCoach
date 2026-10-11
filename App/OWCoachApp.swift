import SwiftData
import SwiftUI

@main
struct OWCoachApp: App {
    private let container: ModelContainer
    private let content = BundledContent.load()

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        container = Persistence.makeContainer(inMemory: arguments.contains("-inMemory"))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.content, content)
                .tint(Theme.accent)
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}
