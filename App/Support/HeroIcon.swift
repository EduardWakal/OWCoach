import OWCoachKit
import SwiftUI
import UIKit

struct HeroIcon: View {
    @Environment(\.content) private var content
    let heroID: String
    var size: CGFloat = 44

    var body: some View {
        let hero = content.hero(heroID)
        Group {
            if let hero, UIImage(named: hero.iconAsset) != nil {
                Image(hero.iconAsset).resizable().scaledToFill()
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.22)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .background(Theme.color(for: hero?.role ?? .damage).opacity(0.25))
        .clipShape(Circle())
        .accessibilityLabel(hero?.name ?? heroID)
    }
}
