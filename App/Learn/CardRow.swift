import OWCoachKit
import SwiftUI

struct CardRow: View {
    let card: Card
    let status: CardStatus

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.title).font(.headline)
                Text(card.question).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.leading)
            }
            Spacer(minLength: 8)
            CardStatusBadge(status: status)
            Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.tertiary)
        }
        .frame(minHeight: 52)
        .contentShape(.rect)
    }
}
