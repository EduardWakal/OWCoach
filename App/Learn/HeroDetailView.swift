import OWCoachKit
import SwiftData
import SwiftUI

struct HeroDetailView: View {
    @Environment(\.content) private var content
    @Query(sort: \FocusPlan.createdAt) private var plans: [FocusPlan]
    @Query private var progress: [CardProgress]
    @Query(sort: \GameEntry.date) private var entries: [GameEntry]
    let heroID: String

    var body: some View {
        let hero = content.hero(heroID)
        let active = plans.first?.activeCardID
        let mastered = Set(progress.filter { $0.masteredAt != nil }.map(\.cardID))
        let games = entries.map(\.record).filter { $0.heroID == heroID }

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 14) {
                    HeroIcon(heroID: heroID, size: 72)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(hero?.name ?? heroID).font(.largeTitle.bold())
                        Text(hero?.role.label ?? "").font(.subheadline).foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 10) {
                    tile("\(games.count)", "Games")
                    tile(Stats.winRate(games).map { "\(Int(($0 * 100).rounded())) %" } ?? "–", "Winrate")
                    tile(Stats.focusAverage(games).map { $0.formatted(.number.precision(.fractionLength(1))) } ?? "–", "Fokus Ø")
                }

                if let hero, !hero.path.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lernpfad").font(.title3.bold())
                        VStack(spacing: 0) {
                            ForEach(Array(hero.path.enumerated()), id: \.element.id) { index, card in
                                NavigationLink(value: CardRoute(id: card.id)) {
                                    HStack(spacing: 10) {
                                        Text("\(index + 1)").font(.caption.bold()).frame(width: 22).foregroundStyle(.secondary)
                                        CardRow(card: card, status: CardStatus.of(card.id, active: active, mastered: mastered))
                                    }
                                }
                                .buttonStyle(.plain)
                                if card.id != hero.path.last?.id { Divider() }
                            }
                        }
                        .glassPanel()
                    }
                }

                if let hero, !hero.guide.isEmpty {
                    ForEach(hero.guide) { section in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(section.title).font(.title3.bold())
                            ForEach(Array(section.rules.enumerated()), id: \.offset) { _, rule in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                                        Text("•").foregroundStyle(Theme.accent)
                                        Text(rule.text).font(.subheadline)
                                    }
                                    VideoLinks(videos: rule.videos).padding(.leading, 16)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassPanel()
                    }
                } else {
                    ContentUnavailableView("Guide kommt bald", systemImage: "book.closed", description: Text("Für \(hero?.name ?? heroID) gibt es noch keinen Guide."))
                }
            }
            .padding(16)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func tile(_ value: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title3.bold()).monospacedDigit()
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 64)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
}
