import OWCoachKit
import SwiftUI

struct VideoLinks: View {
    let videos: [VideoLink]

    var body: some View {
        if !videos.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(videos, id: \.url) { video in
                        Link(destination: video.url) {
                            Label(video.label, systemImage: "play.fill")
                                .font(.caption.bold())
                                .padding(.horizontal, 12)
                                .frame(minHeight: 36)
                        }
                        .glassEffect(.regular.interactive(), in: .capsule)
                    }
                }
            }
        }
    }
}
