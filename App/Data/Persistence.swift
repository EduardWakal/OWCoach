import SwiftData

enum Persistence {
    static let schema = Schema([GameEntry.self, FocusPlan.self, CardProgress.self, AppSettings.self])

    static func makeContainer(inMemory: Bool) -> ModelContainer {
        if !inMemory {
            let cloud = ModelConfiguration(schema: schema, cloudKitDatabase: .private("iCloud.de.schakal.OWCoach"))
            if let container = try? ModelContainer(for: schema, configurations: cloud) { return container }
        }
        let local = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, configurations: local)
        } catch {
            fatalError("SwiftData store could not be opened: \(error)")
        }
    }
}
