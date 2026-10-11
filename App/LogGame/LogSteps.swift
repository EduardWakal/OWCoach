import OWCoachKit
import SwiftUI

struct RoleStep: View {
    let selected: Role?
    let choose: (Role) -> Void

    var body: some View {
        VStack(spacing: 14) {
            ForEach(Role.allCases) { role in
                ChoiceButton(selected: selected == role, tint: Theme.color(for: role), action: { choose(role) }) {
                    Text(role.label).font(.title2.bold())
                }
            }
        }
    }
}

struct HeroStep: View {
    @Environment(\.content) private var content
    let role: Role?
    let pool: [String]
    let selected: String?
    let choose: (String) -> Void

    var body: some View {
        let heroes = role.map { content.heroes(for: $0).filter { pool.contains($0.id) } } ?? []
        if heroes.isEmpty {
            ContentUnavailableView(
                "Kein \(role?.label ?? "Held") im Pool",
                systemImage: "person.crop.circle.badge.plus",
                description: Text("Füge Helden in den Einstellungen (Zahnrad auf Heute) hinzu.")
            )
        } else {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 14)], spacing: 14) {
                ForEach(heroes) { hero in
                    ChoiceButton(selected: selected == hero.id, tint: Theme.color(for: hero.role), action: { choose(hero.id) }) {
                        VStack(spacing: 6) {
                            HeroIcon(heroID: hero.id, size: 56)
                            Text(hero.name).font(.footnote.bold()).lineLimit(1)
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
        }
    }
}

struct MapStep: View {
    @Environment(\.content) private var content
    let selected: String?
    let choose: (String) -> Void
    @State private var query = ""

    var body: some View {
        let maps = MapSearch.filter(content.maps, query: query)
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Map suchen", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(14)
            .glassEffect(.regular, in: .capsule)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8, pinnedViews: [.sectionHeaders]) {
                    ForEach(MapMode.allCases) { mode in
                        let inMode = maps.filter { $0.mode == mode }
                        if !inMode.isEmpty {
                            Section {
                                ForEach(inMode) { map in
                                    ChoiceButton(selected: selected == map.id, action: { choose(map.id) }) {
                                        HStack(spacing: 12) {
                                            MapThumb(mapID: map.id)
                                            Text(map.name).font(.headline)
                                            Spacer()
                                        }
                                        .padding(.vertical, 6)
                                    }
                                }
                            } header: {
                                Text(mode.label).font(.caption.bold()).foregroundStyle(.secondary).padding(.top, 6)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ResultStep: View {
    let selected: GameResult?
    let choose: (GameResult) -> Void

    var body: some View {
        VStack(spacing: 14) {
            ForEach(GameResult.allCases) { result in
                ChoiceButton(selected: selected == result, tint: tint(result), action: { choose(result) }) {
                    Text(result.label).font(.title2.bold())
                }
            }
        }
    }

    private func tint(_ result: GameResult) -> Color {
        switch result {
        case .win: .green
        case .loss: .red
        case .draw: .gray
        }
    }
}

struct FocusStep: View {
    let card: Card?
    let selected: Int?
    let choose: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(card?.question ?? "Keine Fokus-Karte gesetzt. Wie fokussiert warst du?")
                .font(.title3.weight(.semibold))
            Text("Wie oft hast du dir die Frage gestellt und danach gehandelt?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { value in
                    ChoiceButton(selected: selected == value, action: { choose(value) }) {
                        Text("\(value)").font(.title.bold())
                    }
                }
            }
            HStack {
                Text("nie")
                Spacer()
                Text("ständig")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}

struct DeathStep: View {
    let selected: DeathCause?
    let choose: (DeathCause) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Woran bist du meistens gestorben?").font(.title3.weight(.semibold))
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(DeathCause.allCases) { cause in
                    ChoiceButton(selected: selected == cause, action: { choose(cause) }) {
                        HStack(spacing: 8) {
                            Text(cause.emoji).font(.title2)
                            Text(cause.label).font(.subheadline.bold()).multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                    }
                }
            }
        }
    }
}

struct TiltStep: View {
    let selected: Int?
    let choose: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Wie geht's dir?").font(.title3.weight(.semibold))
            HStack(spacing: 10) {
                ForEach(1...4, id: \.self) { value in
                    ChoiceButton(selected: selected == value, action: { choose(value) }) {
                        Text(Theme.tiltEmoji(value)).font(.system(size: 40))
                    }
                }
            }
        }
    }
}
