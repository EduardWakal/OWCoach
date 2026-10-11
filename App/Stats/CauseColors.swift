import OWCoachKit
import SwiftUI

enum CauseColors {
    static let ordered: [DeathCause] = [.open, .tooFar, .isolated, .surprised, .noExit, .timing, .fair]

    static func color(_ cause: DeathCause) -> Color {
        switch cause {
        case .open: Color(hex: 0x3987E5)
        case .tooFar: Color(hex: 0xD95926)
        case .isolated: Color(hex: 0x199E70)
        case .surprised: Color(hex: 0xC98500)
        case .noExit: Color(hex: 0xD55181)
        case .timing: Color(hex: 0x008300)
        case .fair, .barelyDied: Color(hex: 0x7A7974)
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
}
