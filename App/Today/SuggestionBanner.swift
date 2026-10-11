import OWCoachKit
import SwiftUI

struct SuggestionBanner: View {
    @Environment(\.content) private var content
    let suggestion: Suggestion
    let accept: () -> Void
    let dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(message).font(.subheadline.weight(.semibold))
            HStack(spacing: 10) {
                Button(acceptLabel, action: accept).buttonStyle(.glassProminent)
                Button("Nicht jetzt", action: dismiss).buttonStyle(.glass)
            }
        }
        .glassPanel()
    }

    private func title(_ id: String) -> String {
        content.card(id)?.title ?? id
    }

    private var message: String {
        switch suggestion {
        case .cardMastered(let id): "3 Spieltage mit Fokus 4+ auf „\(title(id))“. Sitzt die Karte?"
        case .switchFocus(let cause, let id): "\(cause.emoji) „\(cause.label)“ war zuletzt oft die Hauptursache. Fokus auf „\(title(id))“?"
        case .moveOn(let id): "10 Spieltage mit „\(title(id))“. Nimm die nächste Karte und wiederhol diese später."
        }
    }

    private var acceptLabel: String {
        switch suggestion {
        case .cardMastered: "Sitzt ✅"
        case .switchFocus: "Fokus setzen"
        case .moveOn: "Nächste Karte"
        }
    }
}
