import OWCoachKit
import SwiftUI

struct StatTiles: View {
    let games: [GameRecord]

    var body: some View {
        let week = Stats.recent(games, days: 7, now: .now)
        let twoWeeks = Stats.recent(games, days: 14, now: .now)
        HStack(spacing: 10) {
            tile(value: Stats.winRate(week).map { "\(Int(($0 * 100).rounded())) %" } ?? "–", label: "Winrate 7 T")
            tile(value: Stats.focusAverage(week).map { $0.formatted(.number.precision(.fractionLength(1))) } ?? "–", label: "Fokus Ø 7 T")
            tile(value: Stats.topDeathCause(twoWeeks).map(\.emoji) ?? "–", label: Stats.topDeathCause(twoWeeks)?.label ?? "Top-Tod 14 T")
        }
    }

    private func tile(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.bold()).monospacedDigit()
            Text(label).font(.caption2).foregroundStyle(.secondary).lineLimit(1).minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 72)
        .glassEffect(.regular, in: .rect(cornerRadius: 18))
    }
}
