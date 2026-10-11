import OSLog
import SwiftData

@MainActor
enum Persistence {
    static let schema = Schema([GameEntry.self, FocusPlan.self, CardProgress.self, AppSettings.self, VODReview.self, Finding.self])
    private(set) static var isCloudBacked = false
    #if LOCAL_ONLY
    private static let localOnly = true
    #else
    private static let localOnly = false
    #endif
    private static let log = Logger(subsystem: "de.schakal.OWCoach", category: "Persistence")

    static func makeContainer(inMemory: Bool) -> ModelContainer {
        if !inMemory, !localOnly {
            let cloud = ModelConfiguration(schema: schema, cloudKitDatabase: .private("iCloud.de.schakal.OWCoach"))
            do {
                let container = try ModelContainer(for: schema, configurations: cloud)
                isCloudBacked = true
                return container
            } catch {
                log.error("CloudKit store failed, falling back to local: \(error.localizedDescription, privacy: .public)")
            }
        }
        let local = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, configurations: local)
        } catch {
            fatalError("SwiftData store could not be opened: \(error)")
        }
    }
}
