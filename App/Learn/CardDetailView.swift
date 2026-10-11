import OWCoachKit
import SwiftData
import SwiftUI

struct CardDetailView: View {
    @Environment(\.content) private var content
    @Environment(\.modelContext) private var context
    @Query(sort: \FocusPlan.createdAt) private var plans: [FocusPlan]
    @Query(sort: \AppSettings.createdAt) private var allSettings: [AppSettings]
    @Query private var progress: [CardProgress]
    @Query(sort: \Finding.date, order: .reverse) private var findings: [Finding]
    let cardID: String

    var body: some View {
        let card = content.card(cardID)
        let owner = content.heroOwning(cardID: cardID)
        let role = owner?.role ?? allSettings.first?.defaultRole
        let mastered = progress.filter { $0.masteredAt != nil }
        let status = CardStatus.of(cardID, active: plans.first?.activeCardID, mastered: Set(mastered.map(\.cardID)))
        let mine = Learnings.forCard(cardID, in: findings.map(\.record))

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let card {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(owner?.name.uppercased() ?? "GRUNDLAGE").font(.caption.bold()).foregroundStyle(.secondary)
                            Spacer()
                            CardStatusBadge(status: status)
                        }
                        Text(card.title).font(.largeTitle.bold())
                        Text(card.question).font(.title3.weight(.semibold)).foregroundStyle(Theme.accent)
                        ForEach(card.points(for: role), id: \.self) { point in
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("•").foregroundStyle(Theme.accent)
                                Text(point)
                            }
                        }
                        VideoLinks(videos: card.videos)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassPanel()

                    actions(status: status, masteredAt: mastered.first { $0.cardID == cardID }?.masteredAt)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Aus deinen VODs").font(.title3.bold())
                        if mine.isEmpty {
                            Text("Noch keine Findings zu dieser Karte.").font(.subheadline).foregroundStyle(.secondary)
                        }
                        ForEach(mine) { finding in
                            FindingRow(finding: finding)
                        }
                    }
                } else {
                    ContentUnavailableView("Karte nicht gefunden", systemImage: "questionmark.square", description: Text(cardID))
                }
            }
            .padding(16)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func actions(status: CardStatus, masteredAt: Date?) -> some View {
        switch status {
        case .open:
            Button {
                FocusActions.setFocus(cardID, in: context)
            } label: {
                Label("Als Fokus setzen", systemImage: "scope").frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.glassProminent)
        case .active:
            Button {
                FocusActions.markMastered(cardID, in: context)
            } label: {
                Label("Sitzt", systemImage: "checkmark.seal").frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.glass)
        case .mastered:
            VStack(spacing: 10) {
                if let masteredAt {
                    Label("Sitzt seit \(masteredAt.formatted(date: .abbreviated, time: .omitted))", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.green)
                }
                Button {
                    FocusActions.setFocus(cardID, in: context)
                } label: {
                    Label("Wiederholen", systemImage: "arrow.counterclockwise").frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.glass)
            }
        }
    }
}

struct FindingRow: View {
    let finding: FindingRecord

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: finding.starred ? "star.fill" : "text.bubble")
                .foregroundStyle(finding.starred ? Theme.accent : .secondary)
            VStack(alignment: .leading, spacing: 4) {
                Text(finding.text).font(.subheadline)
                Text([finding.moment, finding.date.formatted(date: .abbreviated, time: .omitted)].compactMap { $0 }.joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
}
