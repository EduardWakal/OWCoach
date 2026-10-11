import SwiftUI

struct WeekHeroesBar: View {
    let heroIDs: [String]
    let edit: () -> Void

    var body: some View {
        Button(action: edit) {
            HStack(spacing: -10) {
                if heroIDs.isEmpty {
                    Label("Helden der Woche wählen", systemImage: "plus.circle.fill")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 14)
                        .frame(minHeight: 52)
                } else {
                    ForEach(heroIDs, id: \.self) { id in
                        HeroIcon(heroID: id, size: 48)
                            .overlay(Circle().strokeBorder(.background, lineWidth: 2))
                    }
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 18)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Helden der Woche ändern")
    }
}
