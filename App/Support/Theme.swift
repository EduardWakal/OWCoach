import OWCoachKit
import SwiftUI

enum Theme {
    static let accent = Color(red: 0.976, green: 0.620, blue: 0.102)

    static func color(for role: Role) -> Color {
        switch role {
        case .tank: Color(red: 0.30, green: 0.58, blue: 0.96)
        case .damage: Color(red: 0.94, green: 0.35, blue: 0.33)
        case .support: Color(red: 0.38, green: 0.82, blue: 0.50)
        }
    }

    static func tiltEmoji(_ tilt: Int) -> String {
        ["😎", "🙂", "😐", "😤"][max(0, min(3, tilt - 1))]
    }
}

extension View {
    func glassPanel(cornerRadius: CGFloat = 22) -> some View {
        padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
    }
}
