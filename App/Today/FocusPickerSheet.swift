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
                ForEach(weekRoles, id: \.self) { role in
                    Section(role.label) {
                        ForEach(content.cards(for: role)) { row($0) }
                    }
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

    private var weekRoles: [Role] {
        let played = Set(weekHeroIDs.compactMap { content.hero($0)?.role })
        return Role.allCases.filter { played.contains($0) && !content.cards(for: $0).isEmpty }
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
