import OWCoachKit
import SwiftUI

struct TodayGamesList: View {
    @Environment(\.content) private var content
    let games: [GameEntry]
    let delete: (GameEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Heute · \(games.count) \(games.count == 1 ? "Game" : "Games")").font(.headline)
            if games.isEmpty {
                Text("Noch kein Game geloggt.").font(.subheadline).foregroundStyle(.secondary)
            }
            ForEach(games) { entry in
                let record = entry.record
                HStack(spacing: 12) {
                    HeroIcon(heroID: record.heroID, size: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(content.map(record.mapID)?.name ?? record.mapID).font(.subheadline.bold())
                        Text("\(record.deathCause.emoji) \(record.deathCause.label)").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("F\(record.focus)").font(.caption.bold()).monospacedDigit()
                    Text(Theme.tiltEmoji(record.tilt))
                    Text(record.result == .win ? "W" : record.result == .loss ? "L" : "D")
                        .font(.caption.bold())
                        .frame(width: 26, height: 26)
                        .background(record.result == .win ? .green.opacity(0.35) : record.result == .loss ? .red.opacity(0.35) : .gray.opacity(0.35), in: Circle())
                }
                .frame(minHeight: 52)
                .contextMenu {
                    Button("Löschen", systemImage: "trash", role: .destructive) { delete(entry) }
                }
            }
        }
        .glassPanel()
    }
}
