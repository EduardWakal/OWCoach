import CoreData
import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @State private var tab = UserDefaults.standard.string(forKey: "startTab") ?? "today"

    var body: some View {
        TabView(selection: $tab) {
            Tab("Heute", systemImage: "flame.fill", value: "today") {
                TodayView()
            }
            Tab("Lernen", systemImage: "book.fill", value: "learn") {
                LearnView()
            }
            Tab("VOD", systemImage: "play.rectangle.fill", value: "vod") {
                VODListView()
            }
            Tab("Stats", systemImage: "chart.bar.fill", value: "stats") {
                StatsView()
            }
        }
        .onAppear { Singletons.consolidate(in: context) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Singletons.consolidate(in: context) }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange).receive(on: RunLoop.main)) { _ in
            Singletons.consolidate(in: context)
        }
    }
}
