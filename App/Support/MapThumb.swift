import OWCoachKit
import SwiftUI
import UIKit

struct MapThumb: View {
    @Environment(\.content) private var content
    let mapID: String
    var width: CGFloat = 72

    var body: some View {
        let map = content.map(mapID)
        Group {
            if let map, UIImage(named: map.imageAsset) != nil {
                Image(map.imageAsset).resizable().scaledToFill()
            } else {
                Image(systemName: "map").foregroundStyle(.secondary)
            }
        }
        .frame(width: width, height: width * 9 / 16)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
