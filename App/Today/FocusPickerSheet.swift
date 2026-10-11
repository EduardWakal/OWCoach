import OWCoachKit
import SwiftUI

struct FocusPickerSheet: View {
    @Environment(\.content) private var content
    @Environment(\.dismiss) private var dismiss
    let weekHeroIDs: [String]
    let activeCardID: String?
    let mastered: Set<String>
    let choose: (String) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Grundlagen") {
                    ForEach(content.basics) { row($0) }
                }
                ForEach(weekHeroIDs.compactMap(content.hero)) { hero in
                    if !hero.path.isEmpty {
                        Section(hero.name) {
                            ForEach(hero.path) { row($0) }
                        }
                    }
                }
            }
            .navigationTitle("Fokus wählen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
            }
        }
    }

    private func row(_ card: Card) -> some View {
        Button {
            choose(card.id)
            dismiss()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(card.title).font(.headline)
                    Text(card.question).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if card.id == activeCardID {
                    Image(systemName: "scope").foregroundStyle(Theme.accent)
                } else if mastered.contains(card.id) {
                    Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                }
            }
            .frame(minHeight: 52)
        }
        .buttonStyle(.plain)
    }
}
