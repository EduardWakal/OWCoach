import OWCoachKit
import SwiftUI

struct FindingEditor: View {
    @Environment(\.content) private var content
    @Environment(\.dismiss) private var dismiss
    let heroID: String
    let finding: Finding?
    let save: (_ cardID: String, _ text: String, _ moment: String?, _ starred: Bool) -> Void

    @State private var cardID: String?
    @State private var text = ""
    @State private var moment = ""
    @State private var starred = false

    var body: some View {
        let hero = content.hero(heroID)
        let offered = content.basics + (hero.map { content.cards(for: $0.role) } ?? []) + (hero?.path ?? [])
        let cards = offered + (cardID.flatMap { id in offered.contains { $0.id == id } ? nil : content.card(id) }.map { [$0] } ?? [])
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    TextField("Wann? z. B. R2 3:40", text: $moment)
                        .padding(14)
                        .glassEffect(.regular, in: .capsule)
                    Text("Zu welcher Karte?").font(.headline)
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                        ForEach(cards) { card in
                            ChoiceButton(selected: cardID == card.id, action: { cardID = card.id }) {
                                Text(card.title).font(.subheadline.bold()).multilineTextAlignment(.center)
                            }
                        }
                    }
                    Text("Was ist passiert?").font(.headline)
                    TextField("Ein Satz", text: $text, axis: .vertical)
                        .lineLimit(2...5)
                        .padding(14)
                        .glassEffect(.regular, in: .rect(cornerRadius: 18))
                    Toggle(isOn: $starred) {
                        Label("Wichtig – auf die Fokus-Karte", systemImage: "star.fill")
                    }
                    .frame(minHeight: 52)
                }
                .padding(16)
            }
            .navigationTitle(finding == nil ? "Neues Finding" : "Finding")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sichern") {
                        guard let cardID else { return }
                        let trimmedMoment = moment.trimmingCharacters(in: .whitespaces)
                        save(cardID, text.trimmingCharacters(in: .whitespacesAndNewlines), trimmedMoment.isEmpty ? nil : trimmedMoment, starred)
                        dismiss()
                    }
                    .disabled(cardID == nil || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                guard let finding else { return }
                cardID = finding.cardID
                text = finding.text
                moment = finding.moment ?? ""
                starred = finding.starred
            }
        }
    }
}
