import OWCoachKit
import SwiftUI

struct CardStatusBadge: View {
    let status: CardStatus

    var body: some View {
        switch status {
        case .open:
            EmptyView()
        case .active:
            Label("Fokus", systemImage: "scope")
                .font(.caption.bold())
                .foregroundStyle(Theme.accent)
        case .mastered:
            Label("Sitzt", systemImage: "checkmark.seal.fill")
                .font(.caption.bold())
                .foregroundStyle(.green)
        }
    }
}
