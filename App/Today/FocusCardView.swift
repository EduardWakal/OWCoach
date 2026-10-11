import OWCoachKit
import SwiftUI

struct FocusCardView: View {
    @Environment(\.content) private var content
    let card: Card?
    let role: Role?
    let change: () -> Void

    var body: some View {
        Button(action: change) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("FOKUS").font(.caption.bold()).foregroundStyle(Theme.accent)
                    if let card, let hero = content.heroOwning(cardID: card.id) {
                        Text("· \(hero.name)").font(.caption.bold()).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "arrow.triangle.2.circlepath").foregroundStyle(.secondary)
                }
                if let card {
                    Text(card.title).font(.title2.bold())
                    Text(card.question).font(.title3.weight(.semibold)).foregroundStyle(Theme.accent)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(card.points(for: role), id: \.self) { point in
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("•").foregroundStyle(Theme.accent)
                                Text(point).font(.subheadline)
                            }
                        }
                    }
                } else {
                    Text("Noch keine Fokus-Karte").font(.title3.bold())
                    Text("Tippe, um eine Karte zu wählen. Eine Karte, voller Kopf.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .multilineTextAlignment(.leading)
            .glassPanel()
        }
        .buttonStyle(.plain)
    }
}
