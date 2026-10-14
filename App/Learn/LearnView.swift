import OWCoachKit
import SwiftData
import SwiftUI

struct LearnView: View {
    @Environment(\.content) private var content
    @Query(sort: \FocusPlan.createdAt) private var plans: [FocusPlan]
    @Query(sort: \AppSettings.createdAt) private var allSettings: [AppSettings]
    @Query private var progress: [CardProgress]

    var body: some View {
        let active = plans.first?.activeCardID
        let mastered = Set(progress.filter { $0.masteredAt != nil }.map(\.cardID))
        let pool = allSettings.first?.poolHeroIDs ?? []

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Grundlagen").font(.title3.bold())
                        Text("Gelten für jeden Helden").font(.caption).foregroundStyle(.secondary)
                    }
                    VStack(spacing: 0) {
                        ForEach(content.basics) { card in
                            NavigationLink(value: CardRoute(id: card.id)) {
                                CardRow(card: card, status: CardStatus.of(card.id, active: active, mastered: mastered))
                            }
                            .buttonStyle(.plain)
                            if card.id != content.basics.last?.id { Divider() }
                        }
                    }
                    .glassPanel()

                    ForEach(Role.allCases) { role in
                        let heroes = content.heroes(for: role).sorted { (pool.contains($0.id) ? 0 : 1, $0.name) < (pool.contains($1.id) ? 0 : 1, $1.name) }
                        let roleCards = content.cards(for: role)
                        if !heroes.isEmpty || !roleCards.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(role.label).font(.title3.bold())
                                if !roleCards.isEmpty {
                                    VStack(spacing: 0) {
                                        ForEach(roleCards) { card in
                                            NavigationLink(value: CardRoute(id: card.id)) {
                                                CardRow(card: card, status: CardStatus.of(card.id, active: active, mastered: mastered))
                                            }
                                            .buttonStyle(.plain)
                                            if card.id != roleCards.last?.id { Divider() }
                                        }
                                    }
                                    .glassPanel()
                                }
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 12)], spacing: 12) {
                                    ForEach(heroes) { hero in
                                        NavigationLink(value: HeroRoute(id: hero.id)) {
                                            VStack(spacing: 6) {
                                                HeroIcon(heroID: hero.id, size: 60)
                                                Text(hero.name).font(.footnote.bold()).lineLimit(1)
                                            }
                                            .frame(maxWidth: .infinity, minHeight: 96)
                                            .contentShape(.rect)
                                            .opacity(pool.contains(hero.id) ? 1 : 0.45)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Lernen")
            .navigationDestination(for: CardRoute.self) { CardDetailView(cardID: $0.id) }
            .navigationDestination(for: HeroRoute.self) { HeroDetailView(heroID: $0.id) }
        }
    }
}
