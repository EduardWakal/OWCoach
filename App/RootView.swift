import CoreData
import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            Tab("Heute", systemImage: "flame.fill") {
                TodayView()
            }
            Tab("Lernen", systemImage: "book.fill") {
                LearnView()
            }
            Tab("VOD", systemImage: "play.rectangle.fill") {
                VODListView()
            }
            Tab("Stats", systemImage: "chart.bar.fill") {
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
