import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            Tab("Heute", systemImage: "flame.fill") {
                Text("Heute")
            }
            Tab("Lernen", systemImage: "book.fill") {
                ComingSoon(title: "Lernen")
            }
            Tab("VOD", systemImage: "play.rectangle.fill") {
                ComingSoon(title: "VOD")
            }
            Tab("Stats", systemImage: "chart.bar.fill") {
                ComingSoon(title: "Stats")
            }
        }
    }
}

struct ComingSoon: View {
    let title: String

    var body: some View {
        ContentUnavailableView(title, systemImage: "hammer", description: Text("Kommt im nächsten Update."))
    }
}
