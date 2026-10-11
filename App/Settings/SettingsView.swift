import OWCoachKit
import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.content) private var content
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var defaultRole: Role?
    @State private var mode = "5v5"
    @State private var pool: [String] = []

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Standard-Rolle", selection: $defaultRole) {
                        Text("Keine").tag(Role?.none)
                        ForEach(Role.allCases) { Text($0.label).tag(Role?.some($0)) }
                    }
                    Picker("Modus", selection: $mode) {
                        Text("5v5").tag("5v5")
                        Text("6v6").tag("6v6")
                    }
                    .pickerStyle(.segmented)
                } footer: {
                    Text("Die Standard-Rolle ist beim Game loggen schon angetippt.")
                }

                ForEach(Role.allCases) { role in
                    Section("Pool · \(role.label)") {
                        ForEach(content.heroes(for: role)) { hero in
                            Toggle(isOn: binding(for: hero.id)) {
                                HStack(spacing: 12) {
                                    HeroIcon(heroID: hero.id, size: 36)
                                    Text(hero.name)
                                }
                            }
                            .frame(minHeight: 52)
                        }
                    }
                }

                Section("Sicherung") {
                    if FileManager.default.ubiquityIdentityToken != nil {
                        Label("iCloud aktiv – deine Daten werden gesichert.", systemImage: "icloud.fill")
                    } else {
                        Label("Nicht bei iCloud angemeldet – Daten nur auf diesem iPhone.", systemImage: "icloud.slash")
                            .foregroundStyle(.orange)
                    }
                }
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Fertig") { save(); dismiss() } }
            }
            .onAppear(perform: load)
        }
    }

    private func binding(for id: String) -> Binding<Bool> {
        Binding(
            get: { pool.contains(id) },
            set: { on in
                if on, !pool.contains(id) { pool.append(id) }
                if !on { pool.removeAll { $0 == id } }
            }
        )
    }

    private func load() {
        let settings = AppSettings.current(in: context)
        defaultRole = settings.defaultRole
        mode = settings.mode
        pool = settings.poolHeroIDs
    }

    private func save() {
        let settings = AppSettings.current(in: context)
        settings.defaultRole = defaultRole
        settings.mode = mode
        settings.poolHeroIDs = pool
        let focus = FocusPlan.current(in: context)
        focus.weekHeroIDs = focus.weekHeroIDs.filter(pool.contains)
        try? context.save()
    }
}
