import OWCoachKit
import SwiftUI

struct WeekHeroesSheet: View {
    @Environment(\.content) private var content
    @Environment(\.dismiss) private var dismiss
    let pool: [String]
    @Binding var selection: [String]

    var body: some View {
        NavigationStack {
            List {
                if pool.isEmpty {
                    Text("Dein Pool ist leer. Füge Helden in den Einstellungen hinzu.")
                        .foregroundStyle(.secondary)
                }
                ForEach(content.heroes.filter { pool.contains($0.id) }) { hero in
                    Button {
                        toggle(hero.id)
                    } label: {
                        HStack(spacing: 12) {
                            HeroIcon(heroID: hero.id, size: 40)
                            VStack(alignment: .leading) {
                                Text(hero.name).font(.headline)
                                Text(hero.role.label).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if selection.contains(hero.id) {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.accent)
                            }
                        }
                        .frame(minHeight: 52)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Helden der Woche")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Fertig") { dismiss() } }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func toggle(_ id: String) {
        if let index = selection.firstIndex(of: id) {
            selection.remove(at: index)
        } else {
            selection.append(id)
        }
    }
}
